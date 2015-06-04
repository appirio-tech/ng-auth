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
    var decodeToken, deleteToken, getToken, setToken, tokenIsValid;
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
    tokenIsValid = function() {
      var isString, token;
      token = getToken();
      isString = typeof token === 'string';
      if (isString) {
        return !jwtHelper.isTokenExpired(token);
      } else {
        return false;
      }
    };
    return {
      getToken: getToken,
      deleteToken: deleteToken,
      decodeToken: decodeToken,
      setToken: setToken,
      tokenIsValid: tokenIsValid
    };
  };

  TokenService.$inject = ['$rootScope', '$http', 'store', 'AUTH0_TOKEN_NAME', 'jwtHelper'];

  angular.module('appirio-tech-ng-auth').factory('TokenService', TokenService);

}).call(this);

(function() {
  'use strict';
  var AuthService;

  AuthService = function($rootScope, AuthorizationsAPIService, auth, store, TokenService, $state) {
    var exchangeToken, isAuthenticated, login, logout, refreshToken;
    logout = function() {
      var request;
      request = AuthorizationsAPIService.remove().$promise;
      request.then(function(response, status, headers, config) {
        auth.signout();
        TokenService.deleteToken();
        return $rootScope.$broadcast('logout');
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
      onSuccess = function(profile, idToken, accessToken, state, refreshToken) {
        return exchangeToken(idToken, refreshToken, options.success);
      };
      TokenService.deleteToken();
      if (options.state) {
        store.set('login-state', options.state);
      }
      return auth.signin(params, onSuccess, onError);
    };
    exchangeToken = function(idToken, refreshToken, success, error) {
      var newAuth, onError, onSuccess, params;
      onSuccess = function(res) {
        TokenService.setToken(res.result.content.token);
        $rootScope.$broadcast('authenticated');
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
      var onError, onSuccess;
      onSuccess = function(response) {
        var newToken;
        newToken = response.result.content.token;
        TokenService.setToken(newToken);
        return $rootScope.$broadcast('authenticated');
      };
      onError = function(response) {
        return TokenService.deleteToken();
      };
      return AuthorizationsAPIService.get({
        id: 1
      }).then(onSuccess, onError);
    };
    isAuthenticated = function() {
      return TokenService.tokenIsValid();
    };
    return {
      login: login,
      logout: logout,
      isAuthenticated: isAuthenticated,
      exchangeToken: exchangeToken,
      refreshToken: refreshToken
    };
  };

  AuthService.$inject = ['$rootScope', 'AuthorizationsAPIService', 'auth', 'store', 'TokenService', '$state'];

  angular.module('appirio-tech-ng-auth').factory('AuthService', AuthService);

}).call(this);