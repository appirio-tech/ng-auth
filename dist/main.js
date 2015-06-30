(function() {
  'use strict';
  var config, dependencies, run;

  dependencies = ['ngResource', 'app.constants', 'ui.router', 'angular-storage', 'angular-jwt', 'auth0'];

  config = function($httpProvider, jwtInterceptorProvider, authProvider, AUTH0_DOMAIN, AUTH0_CLIENT_ID) {
    var jwtInterceptor, logout;
    jwtInterceptor = function(TokenService) {
      return TokenService.getToken();
    };
    jwtInterceptor.$inject = ['TokenService'];
    jwtInterceptorProvider.tokenGetter = jwtInterceptor;
    $httpProvider.interceptors.push('jwtInterceptor');
    authProvider.init({
      domain: AUTH0_DOMAIN,
      clientID: AUTH0_CLIENT_ID,
      loginState: 'login'
    });
    logout = function(TokenService) {
      return TokenService.deleteToken();
    };
    logout.$inject = ['TokenService'];
    return authProvider.on('logout', logout);
  };

  run = function($rootScope, $injector, $state, auth, TokenService, AuthService) {
    var checkAuth, checkRedirect;
    auth.hookEvents();
    checkRedirect = function() {
      var isProtected, notLoggedIn;
      isProtected = !toState.data || (toState.data && !toState.data.noAuthRequired);
      notLoggedIn = !AuthService.isAuthenticated();
      if (isProtected && notLoggedIn) {
        $rootScope.preAuthState = toState.name;
        event.preventDefault();
        return $state.go('login');
      }
    };
    return checkAuth = function(event, toState) {
      var isInvalidToken;
      isInvalidToken = TokenService.getToken() && !TokenService.tokenIsValid();
      if (isInvalidToken) {
        AuthService.refreshToken().then(function() {
          return checkRedirect();
        });
      } else {
        checkRedirect();
      }
      return $rootScope.$on('$stateChangeStart', checkAuth);
    };
  };

  config.$inject = ['$httpProvider', 'jwtInterceptorProvider', 'authProvider', 'AUTH0_DOMAIN', 'AUTH0_CLIENT_ID'];

  run.$inject = ['$rootScope', '$injector', '$state', 'auth', 'TokenService', 'AuthService'];

  angular.module('appirio-tech-ng-auth', dependencies).config(config).run(run);

}).call(this);

(function() {
  'use strict';
  var srv;

  srv = function($resource, API_URL) {
    var params, url;
    url = API_URL + '/authorizations/:id';
    params = {
      id: '@id'
    };
    return $resource(url, params);
  };

  srv.$inject = ['$resource', 'API_URL'];

  angular.module('appirio-tech-ng-auth').factory('AuthorizationsAPIService', srv);

}).call(this);

(function() {
  'use strict';
  var TokenService;

  TokenService = function($rootScope, $http, store, AUTH0_TOKEN_NAME, jwtHelper) {
    var decodeToken, deleteToken, getToken, setToken, tokenIsExpired, tokenIsValid;
    getToken = function() {
      return store.get(AUTH0_TOKEN_NAME);
    };
    setToken = function(token) {
      return store.set(AUTH0_TOKEN_NAME, token);
    };
    deleteToken = function() {
      return store.remove(AUTH0_TOKEN_NAME);
    };
    decodeToken = function() {
      var token;
      token = getToken();
      if (token) {
        return jwtHelper.decodeToken(token);
      } else {
        return {};
      }
    };
    tokenIsExpired = function() {
      var isString, token;
      token = getToken();
      isString = typeof token === 'string';
      if (isString) {
        return jwtHelper.isTokenExpired(token);
      } else {
        return true;
      }
    };
    tokenIsValid = function() {
      var isString, token;
      token = getToken();
      isString = typeof token === 'string';
      return isString;
    };
    return {
      getToken: getToken,
      deleteToken: deleteToken,
      decodeToken: decodeToken,
      setToken: setToken,
      tokenIsValid: tokenIsValid,
      tokenIsExpired: tokenIsExpired
    };
  };

  TokenService.$inject = ['$rootScope', '$http', 'store', 'AUTH0_TOKEN_NAME', 'jwtHelper'];

  angular.module('appirio-tech-ng-auth').factory('TokenService', TokenService);

}).call(this);

(function() {
  'use strict';
  var AuthService;

  AuthService = function($rootScope, AuthorizationsAPIService, auth, store, TokenService, $state) {
    var exchangeToken, isAuthenticated, isLoggedIn, loggedIn, login, logout, refreshToken;
    loggedIn = false;
    isLoggedIn = function() {
      return loggedIn;
    };
    logout = function() {
      var request;
      request = AuthorizationsAPIService.remove().$promise;
      request.then(function(response, status, headers, config) {
        auth.signout();
        TokenService.deleteToken();
        return loggedIn = false;
      });
      return request["catch"](function(message) {
        return $state.reload();
      });
    };
    login = function(options) {
      var defaultOptions, lOptions, onError, onSuccess, params;
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
      onError = function(err) {
        return options.error(err);
      };
      onSuccess = function(idToken, refreshToken) {
        return exchangeToken(idToken, refreshToken, options != null ? options.success : void 0);
      };
      TokenService.deleteToken();
      if (options != null ? options.state : void 0) {
        store.set('login-state', options.state);
      }
      return auth.signin(params, onSuccess, onError);
    };
    exchangeToken = function(idToken, refreshToken, success, error) {
      var newAuth, onError, onSuccess, params;
      onSuccess = function(res) {
        TokenService.setToken(res.result.content.token);
        loggedIn = true;
        return typeof success === "function" ? success(res) : void 0;
      };
      onError = function(res) {
        return typeof error === "function" ? error(res) : void 0;
      };
      params = {
        param: {
          refreshToken: refreshToken,
          externalToken: idToken
        }
      };
      newAuth = new AuthorizationsAPIService(params);
      return newAuth.$save(onSuccess, onError);
    };
    refreshToken = function() {
      var onError, onSuccess, resource;
      onSuccess = function(response) {
        var newToken;
        newToken = response.result.content.token;
        TokenService.setToken(newToken);
        return loggedIn = true;
      };
      onError = function(response) {
        TokenService.deleteToken();
        return loggedIn = false;
      };
      resource = AuthorizationsAPIService.get({
        id: 1
      }).$promise;
      resource.then(onSuccess);
      return resource["catch"](onError);
    };
    isAuthenticated = function() {
      if (TokenService.tokenIsValid()) {
        if (TokenService.tokenIsExpired()) {
          refreshToken();
        }
        return true;
      } else {
        return false;
      }
    };
    return {
      login: login,
      logout: logout,
      isLoggedIn: isLoggedIn,
      isAuthenticated: isAuthenticated,
      exchangeToken: exchangeToken,
      refreshToken: refreshToken
    };
  };

  AuthService.$inject = ['$rootScope', 'AuthorizationsAPIService', 'auth', 'store', 'TokenService', '$state'];

  angular.module('appirio-tech-ng-auth').factory('AuthService', AuthService);

}).call(this);

(function() {
  'use strict';
  var srv, transformResponse;

  transformResponse = function(response) {
    var parsed, ref;
    parsed = JSON.parse(response);
    return (parsed != null ? (ref = parsed.result) != null ? ref.content : void 0 : void 0) || {};
  };

  srv = function($resource, API_URL) {
    var actions, params, url;
    url = API_URL + '/users/:id';
    params = {
      id: '@id'
    };
    actions = {
      get: {
        method: 'GET',
        isArray: false,
        transformResponse: transformResponse
      }
    };
    return $resource(url, params, actions);
  };

  srv.$inject = ['$resource', 'API_URL'];

  angular.module('appirio-tech-ng-auth').factory('UserV3APIService', srv);

}).call(this);

(function() {
  'use strict';
  var srv;

  srv = function(UserV3APIService, TokenService, AuthService, $rootScope) {
    var createUser, currentUser, getCurrentUser;
    currentUser = null;
    getCurrentUser = function(callback) {
      var decodedToken, params, resource;
      if (callback == null) {
        callback = null;
      }
      if (currentUser) {
        return currentUser;
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
    createUser = function(options, callback, onError) {
      var resource, userParams;
      if (options.handle && options.email && options.password) {
        userParams = {
          params: {
            handle: options.handle,
            email: options.email,
            utmSource: options.utmSource || 'asp',
            utmMedium: options.utmMedium || '',
            utmCampaign: options.utmCampaign || '',
            firstName: options.firstname,
            lastName: options.lastname,
            credential: {
              password: options.password
            }
          }
        };
        resource = UserV3APIService.save(userParams);
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
        return getCurrentUser();
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
