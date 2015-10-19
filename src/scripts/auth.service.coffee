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

    # Return a promise here for API consistency
    $q.when(true)

  # TODO: Replace this method with a straight $http/$resource call
  # TODO: Remove the auth0 library
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

  getNewJWT = ->
    params =
      param:
        refreshToken: TokenService.getAuth0RefreshToken()
        externalToken: TokenService.getAuth0Token()

    newAuth = new AuthorizationsAPIService params

    newAuth.$save().then (res) ->
      res.result?.content?.token

  setJWT = (JWT) ->
    TokenService.setAppirioJWT JWT

  login = (options) ->
    success = options.success || angular.noop
    error = options.error || angular.noop

    auth0Signin(options)
      .then(setAuth0Tokens)
      .then(getNewJWT)
      .then(setJWT)
      .then(success)
      .catch(error)

  login      : login
  logout     : logout
  isLoggedIn : isLoggedIn

AuthService.$inject = [
 'AuthorizationsAPIService'
 'auth'
 'TokenService'
  '$q'
]

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
