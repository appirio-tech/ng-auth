'use strict'

TokenService = (
  $rootScope
  $http
  store
  AUTH0_TOKEN_NAME
  jwtHelper
) ->
  getToken = ->
    # the angular-store module takes care of the caching
    store.get AUTH0_TOKEN_NAME

  setToken = (token) ->
    store.set AUTH0_TOKEN_NAME, token

  deleteToken = ->
    store.remove AUTH0_TOKEN_NAME

  decodeToken = ->
    token = getToken()

    if token
      jwtHelper.decodeToken(token)
    else
      {}

  tokenIsValid = ->
    token = getToken()

    isString = (typeof token == 'string')
    notExpired = !jwtHelper.isTokenExpired token

    isString && notExpired

  getToken    : getToken
  deleteToken : deleteToken
  decodeToken : decodeToken
  setToken    : setToken
  tokenIsValid: tokenIsValid

TokenService.$inject = [
  '$rootScope'
  '$http'
  'store'
  'AUTH0_TOKEN_NAME'
  'jwtHelper'
]

angular.module('appirio-tech-ng-auth').factory 'TokenService', TokenService
