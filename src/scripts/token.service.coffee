'use strict'

TokenService = (
  store
  AUTH0_TOKEN_NAME
  AUTH0_REFRESH_TOKEN_NAME
  jwtHelper
) ->
  getToken = ->
    store.get AUTH0_TOKEN_NAME

  setToken = (token) ->
    store.set AUTH0_TOKEN_NAME, token

  storeRefreshToken = (token) ->
    store.set AUTH0_REFRESH_TOKEN_NAME, token

  getRefreshToken = (token) ->
    store.get AUTH0_REFRESH_TOKEN_NAME, token

  deleteToken = ->
    store.remove AUTH0_TOKEN_NAME

  deleteRefreshToken = ->
    store.remove AUTH0_REFRESH_TOKEN_NAME

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

  getToken          : getToken
  deleteToken       : deleteToken
  decodeToken       : decodeToken
  setToken          : setToken
  tokenIsValid      : tokenIsValid
  tokenIsExpired    : tokenIsExpired
  storeRefreshToken : storeRefreshToken
  getRefreshToken   : getRefreshToken
  deleteRefreshToken: deleteRefreshToken

TokenService.$inject = [
  'store'
  'AUTH0_TOKEN_NAME'
  'AUTH0_REFRESH_TOKEN_NAME'
  'jwtHelper'
]

angular.module('appirio-tech-ng-auth').factory 'TokenService', TokenService
