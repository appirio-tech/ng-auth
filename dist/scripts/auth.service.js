(function() {
  'use strict';
  var AuthService;

  AuthService = function($rootScope, AuthorizationsAPIService, auth, store, TokenService, $state) {
    var exchangeToken, isAuthenticated, login, logout, refreshToken;
    logout = function() {
      var logoutComplete;
      logoutComplete = function(response, status, headers, config) {
        auth.signout();
        TokenService.deleteToken();
        return $rootScope.$broadcast('logout');
      };
      return AuthorizationsAPIService.remove().then(logoutComplete)["catch"](function(message) {
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
