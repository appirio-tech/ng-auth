'use strict'

AuthService = (
  AuthorizationsAPIService
  auth
  store
  TokenService
  $q
) ->
  loggedIn = TokenService.tokenIsValid()

  isLoggedIn = ->
    loggedIn

  setLoggedInFromStore = ->
    loggedIn = TokenService.tokenIsValid()
    auth.isAuthenticated = TokenService.tokenIsValid()

  logout = ->
    loggedIn = false
    auth.signout()
    TokenService.deleteAllTokens()

    $q.when(true)

  # Currently Auth0
  externalLogin = (options) ->
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
      deferred.resolve(idToken, refreshToken)

    auth.signin params, signinSuccess, signinError

    deferred.promise

  setExternalTokens = (externalToken, refreshToken) ->
    TokenService.setExternalToken externalToken
    TokenService.setRefreshToken refreshToken

  getNewToken = ->
    params =
      param:
        refreshToken: TokenService.getRefreshToken()
        externalToken: TokenService.getExternalToken()

    newAuth = new AuthorizationsAPIService params

    newAuth.$save().then (res) ->
      newToken = res.result?.content?.token

      TokenService.setToken newToken

      newToken

  login = (options) ->
    success = options.success || angular.noop
    error = options.error || angular.noop

    externalLogin(options)
      .then(setExternalTokens)
      .then(getNewToken)
      .then(setLoggedInFromStore)
      .then(success)
      .catch(error)

  setLoggedInFromStore : setLoggedInFromStore
  login                : login
  logout               : logout
  isLoggedIn           : isLoggedIn
  getNewToken          : getNewToken

AuthService.$inject = [
 'AuthorizationsAPIService'
 'auth'
 'store'
 'TokenService'
  '$q'
]

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
