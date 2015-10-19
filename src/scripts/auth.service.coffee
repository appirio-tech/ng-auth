'use strict'

AuthService = (
  AuthorizationsAPIService
  auth
  TokenService
  $q
) ->
  isLoggedIn = ->
    auth.isAuthenticated

  updateStatus = ->
    auth.isAuthenticated = TokenService.tokenIsValid()

  logout = ->
    auth.signout()

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
      # TODO: Remove this dirty hack
      # Without this UserService kicks of its loadUser method too early
      auth.isAuthenticated = false

      deferred.resolve
        external: idToken
        refresh: refreshToken

    auth.signin params, signinSuccess, signinError

    deferred.promise

  setAuth0Tokens = (tokens) ->
    TokenService.setExternalToken tokens.external
    TokenService.setRefreshToken tokens.refresh

  setJWT = (jwt) ->
    TokenService.setToken jwt

  getNewJWT = ->
    params =
      param:
        refreshToken: TokenService.getRefreshToken()
        externalToken: TokenService.getExternalToken()

    newAuth = new AuthorizationsAPIService params

    newAuth.$save().then (res) ->
      res.result?.content?.token

  login = (options) ->
    success = options.success || angular.noop
    error = options.error || angular.noop

    auth0Signin(options)
      .then(setAuth0Tokens)
      .then(getNewJWT)
      .then(setJWT)
      .then(updateStatus)
      .then(success)
      .catch(error)

  updateStatus : updateStatus
  login        : login
  logout       : logout
  isLoggedIn   : isLoggedIn
  getNewJWT    : getNewJWT

AuthService.$inject = [
 'AuthorizationsAPIService'
 'auth'
 'TokenService'
  '$q'
]

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
