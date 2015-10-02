'use strict'

TokenService = (
  store
  AUTH0_TOKEN_NAME
  AUTH0_REFRESH_TOKEN_NAME
  jwtHelper
) ->
  setToken = (token) ->
    store.set AUTH0_TOKEN_NAME, token

  getToken = ->
    store.get AUTH0_TOKEN_NAME

  deleteToken = ->
    store.remove AUTH0_TOKEN_NAME

  setRefreshToken = (token) ->
    store.set AUTH0_REFRESH_TOKEN_NAME, token

  getRefreshToken = (token) ->
    store.get AUTH0_REFRESH_TOKEN_NAME, token

  deleteRefreshToken = ->
    store.remove AUTH0_REFRESH_TOKEN_NAME

  setExternalToken = (token) ->
    store.set 'auth0Jwt', token

  getExternalToken = (token) ->
    store.get 'auth0Jwt', token

  deleteExternalToken = ->
    store.remove 'auth0Jwt'

  deleteAllTokens = ->
    deleteToken()
    deleteRefreshToken()
    deleteExternalToken()

  decodeToken = ->
    token = getToken()

    if token
      jwtHelper.decodeToken(token)
    else
      {}

  tokenIsExpired = ->
    token    = getToken()
    isString = (typeof token == 'string')

    if isString
      jwtHelper.isTokenExpired token
    else
      true

  tokenIsValid = ->
    token    = getToken()
    isString = (typeof token == 'string')

    isString

  setToken            : setToken
  getToken            : getToken
  deleteToken         : deleteToken
  decodeToken         : decodeToken
  setRefreshToken     : setRefreshToken
  getRefreshToken     : getRefreshToken
  deleteRefreshToken  : deleteRefreshToken
  setExternalToken    : setExternalToken
  getExternalToken    : getExternalToken
  deleteExternalToken : deleteExternalToken
  deleteAllTokens     : deleteAllTokens
  tokenIsValid        : tokenIsValid
  tokenIsExpired      : tokenIsExpired

TokenService.$inject = [
  'store'
  'AUTH0_TOKEN_NAME'
  'AUTH0_REFRESH_TOKEN_NAME'
  'jwtHelper'
]

angular.module('appirio-tech-ng-auth').factory 'TokenService', TokenService
