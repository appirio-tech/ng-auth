'use strict'

TokenService = (
  $rootScope
  $http
  exception
  store
  auth0TokenName
  jwtHelper
  apiUrl
) ->
  getToken = ->
    # the angular-store module takes care of the caching
    store.get auth0TokenName

  setToken = (token) ->
    store.set auth0TokenName, token

  deleteToken = ->
    store.remove auth0TokenName

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

  getToken         : getToken
  deleteToken      : deleteToken
  decodeToken      : decodeToken
  setToken         : setToken
  tokenIsValid     : tokenIsValid
  deleteAuth0Tokens: deleteAuth0Tokens

TokenService.$inject = [
  '$rootScope'
  '$http'
  'exception'
  'store'
  'auth0TokenName'
  'jwtHelper'
  'apiUrl'
]

angular.module('appirio-tech-ng-auth').factory 'TokenService', TokenService
