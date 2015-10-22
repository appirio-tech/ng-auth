(function() {
  'use strict';
  var config, dependencies, run;

  dependencies = ['app.constants', 'angular-storage', 'angular-jwt', 'auth0', 'appirio-tech-ng-api-services'];

  config = function($httpProvider, jwtInterceptorProvider, authProvider, AUTH0_DOMAIN, AUTH0_CLIENT_ID) {
    var jwtInterceptor, refreshingToken;
    authProvider.init({
      domain: AUTH0_DOMAIN,
      clientID: AUTH0_CLIENT_ID,
      loginState: 'login'
    });
    refreshingToken = null;
    jwtInterceptor = function(TokenService, $http, API_URL) {
      var currentToken, handleRefreshResponse, refreshingTokenComplete;
      currentToken = TokenService.getAppirioJWT();
      handleRefreshResponse = function(res) {
        var newToken, ref, ref1, ref2;
        newToken = (ref = res.data) != null ? (ref1 = ref.result) != null ? (ref2 = ref1.content) != null ? ref2.token : void 0 : void 0 : void 0;
        TokenService.setAppirioJWT(newToken);
        return newToken;
      };
      refreshingTokenComplete = function() {
        return refreshingToken = null;
      };
      if (TokenService.tokenIsValid() && TokenService.tokenIsExpired()) {
        if (refreshingToken === null) {
          config = {
            method: 'GET',
            url: API_URL + "/v3/authorizations/1",
            headers: {
              'Authorization': "Bearer " + currentToken
            }
          };
          refreshingToken = $http(config).then(handleRefreshResponse)["finally"](refreshingTokenComplete);
        }
        return refreshingToken;
      } else {
        return currentToken;
      }
    };
    jwtInterceptor.$inject = ['TokenService', '$http', 'API_URL'];
    jwtInterceptorProvider.tokenGetter = jwtInterceptor;
    return $httpProvider.interceptors.push('jwtInterceptor');
  };

  run = function(auth, $rootScope, AuthService) {
    return auth.hookEvents();
  };

  config.$inject = ['$httpProvider', 'jwtInterceptorProvider', 'authProvider', 'AUTH0_DOMAIN', 'AUTH0_CLIENT_ID'];

  run.$inject = ['auth', '$rootScope', 'AuthService'];

  angular.module('appirio-tech-ng-auth', dependencies).config(config).run(run);

}).call(this);

(function() {
  'use strict';
  var AuthService;

  AuthService = function(AuthorizationsAPIService, auth, TokenService, $q) {
    var auth0Signin, getNewJWT, isLoggedIn, login, logout, setAuth0Tokens, setJWT;
    isLoggedIn = function() {
      return TokenService.tokenIsValid();
    };
    logout = function() {
      TokenService.deleteAllTokens();
      return $q.when(true);
    };
    auth0Signin = function(options) {
      var defaultOptions, deferred, lOptions, params, signinError, signinSuccess;
      deferred = $q.defer();
      defaultOptions = {
        retUrl: '/'
      };
      lOptions = angular.extend({}, options, defaultOptions);
      params = {
        username: lOptions.username,
        password: lOptions.password,
        sso: false,
        connection: 'LDAP',
        authParams: {
          scope: 'openid profile offline_access'
        }
      };
      signinError = function(err) {
        return deferred.reject(err);
      };
      signinSuccess = function(profile, idToken, accessToken, state, refreshToken) {
        return deferred.resolve({
          identity: idToken,
          refresh: refreshToken
        });
      };
      auth.signin(params, signinSuccess, signinError);
      return deferred.promise;
    };
    setAuth0Tokens = function(tokens) {
      TokenService.setAuth0Token(tokens.identity);
      return TokenService.setAuth0RefreshToken(tokens.refresh);
    };
    getNewJWT = function() {
      var newAuth, params;
      params = {
        param: {
          refreshToken: TokenService.getAuth0RefreshToken(),
          externalToken: TokenService.getAuth0Token()
        }
      };
      newAuth = new AuthorizationsAPIService(params);
      return newAuth.$save().then(function(res) {
        var ref, ref1;
        return (ref = res.result) != null ? (ref1 = ref.content) != null ? ref1.token : void 0 : void 0;
      });
    };
    setJWT = function(JWT) {
      return TokenService.setAppirioJWT(JWT);
    };
    login = function(options) {
      var error, success;
      success = options.success || angular.noop;
      error = options.error || angular.noop;
      return auth0Signin(options).then(setAuth0Tokens).then(getNewJWT).then(setJWT).then(success)["catch"](error);
    };
    return {
      login: login,
      logout: logout,
      isLoggedIn: isLoggedIn
    };
  };

  AuthService.$inject = ['AuthorizationsAPIService', 'auth', 'TokenService', '$q'];

  angular.module('appirio-tech-ng-auth').factory('AuthService', AuthService);

}).call(this);

(function() {
  'use strict';
  var TokenService;

  TokenService = function(store, AUTH0_TOKEN_NAME, AUTH0_REFRESH_TOKEN_NAME, jwtHelper) {
    var decodeToken, deleteAllTokens, deleteAppirioJWT, deleteAuth0RefreshToken, deleteAuth0Token, getAppirioJWT, getAuth0RefreshToken, getAuth0Token, setAppirioJWT, setAuth0RefreshToken, setAuth0Token, tokenIsExpired, tokenIsValid;
    setAppirioJWT = function(token) {
      return store.set(AUTH0_TOKEN_NAME, token);
    };
    getAppirioJWT = function() {
      return store.get(AUTH0_TOKEN_NAME);
    };
    deleteAppirioJWT = function() {
      return store.remove(AUTH0_TOKEN_NAME);
    };
    setAuth0RefreshToken = function(token) {
      return store.set(AUTH0_REFRESH_TOKEN_NAME, token);
    };
    getAuth0RefreshToken = function(token) {
      return store.get(AUTH0_REFRESH_TOKEN_NAME, token);
    };
    deleteAuth0RefreshToken = function() {
      return store.remove(AUTH0_REFRESH_TOKEN_NAME);
    };
    setAuth0Token = function(token) {
      return store.set('auth0Jwt', token);
    };
    getAuth0Token = function(token) {
      return store.get('auth0Jwt', token);
    };
    deleteAuth0Token = function() {
      return store.remove('auth0Jwt');
    };
    deleteAllTokens = function() {
      deleteAppirioJWT();
      deleteAuth0RefreshToken();
      return deleteAuth0Token();
    };
    decodeToken = function() {
      var token;
      token = getAppirioJWT();
      if (token) {
        return jwtHelper.decodeToken(token);
      } else {
        return {};
      }
    };
    tokenIsExpired = function() {
      var isString, token;
      token = getAppirioJWT();
      isString = typeof token === 'string';
      if (isString) {
        return jwtHelper.isTokenExpired(token, 300);
      } else {
        return true;
      }
    };
    tokenIsValid = function() {
      var isString, token;
      token = getAppirioJWT();
      isString = typeof token === 'string';
      return isString;
    };
    return {
      setAppirioJWT: setAppirioJWT,
      getAppirioJWT: getAppirioJWT,
      deleteAppirioJWT: deleteAppirioJWT,
      decodeToken: decodeToken,
      setAuth0RefreshToken: setAuth0RefreshToken,
      getAuth0RefreshToken: getAuth0RefreshToken,
      deleteAuth0RefreshToken: deleteAuth0RefreshToken,
      setAuth0Token: setAuth0Token,
      getAuth0Token: getAuth0Token,
      deleteAuth0Token: deleteAuth0Token,
      deleteAllTokens: deleteAllTokens,
      tokenIsValid: tokenIsValid,
      tokenIsExpired: tokenIsExpired
    };
  };

  TokenService.$inject = ['store', 'AUTH0_TOKEN_NAME', 'AUTH0_REFRESH_TOKEN_NAME', 'jwtHelper'];

  angular.module('appirio-tech-ng-auth').factory('TokenService', TokenService);

}).call(this);

(function() {
  'use strict';
  var srv;

  srv = function(UserV3APIService, TokenService, AuthService, $rootScope) {
    var createUser, currentUser, getCurrentUser, loadUser;
    currentUser = null;
    loadUser = function(callback) {
      var decodedToken, params, resource;
      if (callback == null) {
        callback = null;
      }
      decodedToken = TokenService.decodeToken();
      if (decodedToken.userId) {
        params = {
          id: decodedToken.userId
        };
        resource = UserV3APIService.get(params);
        resource.$promise.then(function(response) {
          return currentUser = response;
        });
        resource.$promise["catch"](function() {});
        return resource.$promise["finally"](function() {});
      }
    };
    getCurrentUser = function() {
      return currentUser;
    };
    createUser = function(options, callback, onError) {
      var resource, userParams;
      if (options.handle && options.email && options.password) {
        userParams = {
          param: {
            handle: options.handle,
            email: options.email,
            utmSource: options.utmSource || 'asp',
            utmMedium: options.utmMedium || '',
            utmCampaign: options.utmCampaign || '',
            firstName: options.firstname || '',
            lastName: options.lastname || '',
            credential: {
              password: options.password
            }
          }
        };
        if (options.afterActivationURL) {
          userParams.options = {
            afterActivationURL: options.afterActivationURL
          };
        }
        resource = UserV3APIService.post(userParams);
        resource.$promise.then(function(response) {
          return typeof callback === "function" ? callback(response) : void 0;
        });
        resource.$promise["catch"](function(response) {
          return typeof onError === "function" ? onError(response) : void 0;
        });
        return resource.$promise["finally"](function(response) {});
      }
    };
    $rootScope.$watch(AuthService.isLoggedIn, function() {
      currentUser = null;
      if (AuthService.isLoggedIn()) {
        return loadUser();
      }
    });
    return {
      getCurrentUser: getCurrentUser,
      createUser: createUser
    };
  };

  srv.$inject = ['UserV3APIService', 'TokenService', 'AuthService', '$rootScope'];

  angular.module('appirio-tech-ng-auth').factory('UserV3Service', srv);

}).call(this);
