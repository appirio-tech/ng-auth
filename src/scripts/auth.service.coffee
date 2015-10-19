'use strict'

AuthService = (
  AuthorizationsAPIService
  auth
  TokenService
  $q
) ->
  isLoggedIn = ->
    TokenService.tokenIsValid()

  logout = ->
    TokenService.deleteAllTokens()

    $q.when(true)

  auth0Signin = (options) ->
    deferred = $q.defer()

    defaultOptions =
      retUrl: '/'

    lOptions = angular.extend {}, options, defaultOptions

    params =
      username  : lOptions.username
      password  : lOptions.password
      sso       : false
      connection: 'LDAP'
      authParams:
        scope: 'openid profile offline_access'

    signinError = (err) ->
      deferred.reject(err)

    signinSuccess = (profile, idToken, accessToken, state, refreshToken) ->
      deferred.resolve
        identity: idToken
        refresh: refreshToken

    auth.signin params, signinSuccess, signinError

    deferred.promise

  setAuth0Tokens = (tokens) ->
    TokenService.setAuth0Token tokens.identity
    TokenService.setAuth0RefreshToken tokens.refresh

  refreshAppirioJWT = ->
    params =
      param:
        refreshToken: TokenService.getAuth0RefreshToken()
        externalToken: TokenService.getAuth0Token()

    newAuth = new AuthorizationsAPIService params

    newAuth.$save().then (res) ->
      JWT = res.result?.content?.token

      TokenService.setAppirioJWT JWT

      JWT

  login = (options) ->
    success = options.success || angular.noop
    error = options.error || angular.noop

    auth0Signin(options)
      .then(setAuth0Tokens)
      .then(refreshAppirioJWT)
      .then(success)
      .catch(error)

  login             : login
  logout            : logout
  isLoggedIn        : isLoggedIn
  refreshAppirioJWT : refreshAppirioJWT

AuthService.$inject = [
 'AuthorizationsAPIService'
 'auth'
 'TokenService'
  '$q'
]

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
