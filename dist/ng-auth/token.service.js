(function() {
  'use strict';
  var TokenService;

  TokenService = function($rootScope, $http, exception, store, AUTH0_TOKEN_NAME, jwtHelper, apiUrl) {
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
      var isString, notExpired, token;
      token = getToken();
      isString = typeof token === 'string';
      notExpired = !jwtHelper.isTokenExpired(token);
      return isString && notExpired;
    };
    return {
      getToken: getToken,
      deleteToken: deleteToken,
      decodeToken: decodeToken,
      setToken: setToken,
      tokenIsValid: tokenIsValid,
      deleteAuth0Tokens: deleteAuth0Tokens
    };
  };

  TokenService.$inject = ['$rootScope', '$http', 'exception', 'store', 'AUTH0_TOKEN_NAME', 'jwtHelper', 'apiUrl'];

  angular.module('appirio-tech-ng-auth').factory('TokenService', TokenService);

}).call(this);
