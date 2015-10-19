'use strict'

TokenService = (
  store
  AUTH0_TOKEN_NAME
  AUTH0_REFRESH_TOKEN_NAME
  jwtHelper
) ->
  setAppirioJWT = (token) ->
    store.set AUTH0_TOKEN_NAME, token

  getAppirioJWT = ->
    store.get AUTH0_TOKEN_NAME

  deleteAppirioJWT = ->
    store.remove AUTH0_TOKEN_NAME

  setAuth0RefreshToken = (token) ->
    store.set AUTH0_REFRESH_TOKEN_NAME, token

  getAuth0RefreshToken = (token) ->
    store.get AUTH0_REFRESH_TOKEN_NAME, token

  deleteAuth0RefreshToken = ->
    store.remove AUTH0_REFRESH_TOKEN_NAME

  setAuth0Token = (token) ->
    store.set 'auth0Jwt', token

  getAuth0Token = (token) ->
    store.get 'auth0Jwt', token

  deleteAuth0Token = ->
    store.remove 'auth0Jwt'

  deleteAllTokens = ->
    deleteAppirioJWT()
    deleteAuth0RefreshToken()
    deleteAuth0Token()

  decodeToken = ->
    token = getAppirioJWT()

    if token
      jwtHelper.decodeToken(token)
    else
      {}

  tokenIsExpired = ->
    token    = getAppirioJWT()
    isString = (typeof token == 'string')

    if isString
      jwtHelper.isTokenExpired token
    else
      true

  tokenIsValid = ->
    token    = getAppirioJWT()
    isString = (typeof token == 'string')

    isString

  setAppirioJWT            : setAppirioJWT
  getAppirioJWT            : getAppirioJWT
  deleteAppirioJWT         : deleteAppirioJWT
  decodeToken              : decodeToken
  setAuth0RefreshToken     : setAuth0RefreshToken
  getAuth0RefreshToken     : getAuth0RefreshToken
  deleteAuth0RefreshToken  : deleteAuth0RefreshToken
  setAuth0Token            : setAuth0Token
  getAuth0Token            : getAuth0Token
  deleteAuth0Token         : deleteAuth0Token
  deleteAllTokens          : deleteAllTokens
  tokenIsValid             : tokenIsValid
  tokenIsExpired           : tokenIsExpired

TokenService.$inject = [
  'store'
  'AUTH0_TOKEN_NAME'
  'AUTH0_REFRESH_TOKEN_NAME'
  'jwtHelper'
]

angular.module('appirio-tech-ng-auth').factory 'TokenService', TokenService
