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
