(function() {
  'use strict';
  var config, dependencies;

  dependencies = ['app.constants', 'angular-storage', 'angular-jwt', 'appirio-tech-ng-api-services'];

  config = function($httpProvider, jwtInterceptorProvider) {
    var jwtInterceptor, refreshingToken;
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

  config.$inject = ['$httpProvider', 'jwtInterceptorProvider'];

  angular.module('appirio-tech-ng-auth', dependencies).config(config);

}).call(this);

(function() {
  'use strict';
  var AuthService;

  AuthService = function(AuthorizationsAPIService, TokenService, $q, API_URL, AUTH0_DOMAIN, AUTH0_CLIENT_ID, $http) {
    var auth0Signin, getNewJWT, isLoggedIn, login, logout, resetPassword, sendResetEmail, setAuth0Tokens, setJWT;
    isLoggedIn = function() {
      return TokenService.tokenIsValid();
    };
    logout = function() {
      TokenService.deleteAllTokens();
      return $q.when(true);
    };
    auth0Signin = function(options) {
      var config;
      config = {
        method: 'POST',
        url: "https://" + AUTH0_DOMAIN + "/oauth/ro",
        data: {
          username: options.username,
          password: options.password,
          client_id: AUTH0_CLIENT_ID,
          sso: false,
          scope: 'openid profile offline_access',
          response_type: 'token',
          connection: 'LDAP',
          grant_type: 'password',
          device: 'Browser'
        }
      };
      return $http(config);
    };
    setAuth0Tokens = function(res) {
      TokenService.setAuth0Token(res.data.id_token);
      return TokenService.setAuth0RefreshToken(res.data.fresh_token);
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
    sendResetEmail = function(email) {
      return $http({
        method: 'GET',
        url: API_URL + "/v3/users/resetToken?email=" + email + "&source=connect"
      });
    };
    resetPassword = function(handle, token, password) {
      var config;
      config = {
        method: 'PUT',
        url: API_URL + "/v3/users/resetPassword",
        data: {
          param: {
            handle: handle,
            credential: {
              password: password,
              resetToken: token
            }
          }
        }
      };
      return $http(config);
    };
    return {
      login: login,
      logout: logout,
      isLoggedIn: isLoggedIn,
      sendResetEmail: sendResetEmail,
      resetPassword: resetPassword
    };
  };

  AuthService.$inject = ['AuthorizationsAPIService', 'TokenService', '$q', 'API_URL', 'AUTH0_DOMAIN', 'AUTH0_CLIENT_ID', '$http'];

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

  srv = function(UserV3APIService, profilesAPIService, TokenService, AuthService, $rootScope, $q) {
    var createUser, currentUser, getCurrentUser, loadUser;
    currentUser = null;
    loadUser = function() {
      var decodedToken, params, resource;
      decodedToken = TokenService.decodeToken();
      if (decodedToken.userId) {
        params = {
          id: decodedToken.userId
        };
        resource = profilesAPIService.get(params);
        return resource.$promise.then(function(response) {
          currentUser = response;
          currentUser.id = currentUser.userId;
          currentUser.role = currentUser.isCopilot ? 'copilot' : 'customer';
          return currentUser;
        });
      } else {
        return $q.reject();
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
      createUser: createUser,
      loadUser: loadUser
    };
  };

  srv.$inject = ['UserV3APIService', 'profilesAPIService', 'TokenService', 'AuthService', '$rootScope', '$q'];

  angular.module('appirio-tech-ng-auth').factory('UserV3Service', srv);

}).call(this);
