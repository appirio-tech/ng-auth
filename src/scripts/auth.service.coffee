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

  logout = ->
    loggedIn = false

    auth.signout()
    TokenService.deleteAllTokens()

    AuthorizationsAPIService.remove().$promise

  # Currently Auth0
  externalLogin = (options) ->
    deferred       = $q.defer()

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
      TokenService.setExternalToken idToken
      TokenService.setRefreshToken refreshToken
      deferred.resolve()

    auth.signin params, signinSuccess, signinError

    deferred.promise

  exchangeToken = ->
    console.log 'exchanging:'
    console.log TokenService.getRefreshToken()
    console.log 'AND'
    console.log TokenService.getExternalToken()

    params =
      param:
        refreshToken: TokenService.getRefreshToken()
        externalToken: TokenService.getExternalToken()

    newAuth = new AuthorizationsAPIService params

    newAuth.$save().then (res) ->
      newToken = res.result?.content?.token
      loggedIn = true

      TokenService.setToken newToken

      newToken

  login = (options) ->
    externalLogin(options).then ->
      TokenService.deleteToken()
      # store.set 'login-state', options.state if options?.state
      exchangeToken()

  login          : login
  logout         : logout
  isLoggedIn     : isLoggedIn
  exchangeToken  : exchangeToken

AuthService.$inject = [
 'AuthorizationsAPIService'
 'auth'
 'store'
 'TokenService'
  '$q'
]

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
