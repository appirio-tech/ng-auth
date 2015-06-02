(function() {
  'use strict';
  var AuthService;

  AuthService = function($rootScope, AuthorizationsAPIService, exception, auth, store, TokenService, logger) {
    var exchangeToken, isAuthenticated, login, logout, refreshToken;
    logout = function() {
      var logoutComplete;
      logoutComplete = function(data, status, headers, config) {
        auth.signout();
        TokenService.deleteToken();
        return $rootScope.$broadcast('logout');
      };
      return AuthorizationsAPIService.remove('auth').then(logoutComplete)["catch"](function(message) {
        exception.catcher(message.statusText)(message);
        return $state.reload();
      });
    };
    login = function(options) {
      var defaultOptions, lOptions, onError, onSuccess, params;
      TokenService.deleteToken();
      defaultOptions = {
        retUrl: '/'
      };
      lOptions = angular.extend({}, options, defaultOptions);
      if (options.state) {
        store.set('login-state', options.state);
      }
      params = {
        username: lOptions.username,
        password: lOptions.password,
        sso: false,
        connection: 'LDAP',
        authParams: {
          scope: 'openid profile offline_access'
        }
      };
      auth.signin(params, onSuccess, onError);
      onError = function(err) {
        return options.error(err);
      };
      return onSuccess = function(profile, idToken, accessToken, state, refreshToken) {
        return exchangeToken(idToken, refreshToken, options.success);
      };
    };
    exchangeToken = function(idToken, refreshToken, success, error) {
      var onError, onSuccess, query;
      query = {
        param: {
          refreshToken: refreshToken,
          externalToken: idToken
        }
      };
      onSuccess = function(res) {
        TokenService.setToken(res.result.content.token);
        $rootScope.$broadcast('authenticated');
        return typeof success === "function" ? success(res) : void 0;
      };
      onError = function(res) {
        return typeof error === "function" ? error(res) : void 0;
      };
      return AuthorizationsAPIService.create('auth', query).then(onSuccess, onError);
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
      return AuthorizationsAPIService.get('auth', {
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
      refreshToken: refreshToken,
      register: register
    };
  };

  AuthService.$inject = ['$rootScope', 'AuthorizationsAPIService', 'exception', 'auth', 'store', 'TokenService'];

  angular.module('appirio-tech-ng-auth').factory('AuthService', AuthService);

}).call(this);
