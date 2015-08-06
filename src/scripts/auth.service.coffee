'use strict'

AuthService = (
  $rootScope
  AuthorizationsAPIService
  auth
  store
  TokenService
) ->
  loggedIn = null

  isLoggedIn = ->
    loggedIn

  logout = ->
    auth.signout()
    TokenService.deleteToken()
    TokenService.deleteRefreshToken()

    loggedIn = false
    request  = AuthorizationsAPIService.remove().$promise

    request.then (response, status, headers, config) ->
      # do something

    request.catch (message) ->
      # do something

  login = (options) ->
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

    onError = (err) ->
      options?.error? err

    onSuccess = (profile, idToken, accessToken, state, refreshToken) ->
      exchangeToken idToken, refreshToken, options?.success

    # First remove any old tokens
    TokenService.deleteToken()

    store.set 'login-state', options.state if options?.state

    auth.signin params, onSuccess, onError

  exchangeToken = (idToken, refreshToken, success, error) ->
    TokenService.storeRefreshToken refreshToken

    onSuccess = (res) ->
      TokenService.setToken res.result.content.token
      loggedIn = true

      success?(res)

    onError = (res) ->
      error?(res)

    params =
      param:
        refreshToken: refreshToken
        externalToken: idToken

    newAuth = new AuthorizationsAPIService params

    newAuth.$save onSuccess, onError

  refreshToken = (onSuccess = nil) ->
    token = TokenService.getRefreshToken()

    if token
      promise = auth.refreshIdToken token

      promise.then (response) ->
        TokenService.setToken response

        resource = AuthorizationsAPIService.get(id: 1).$promise

        resource.then (response) ->
          loggedIn = true

          onSuccess?()

        resource.catch (response) ->
          logout()

        promise.catch (response) ->
          logout()

  isAuthenticated = ->
    if TokenService.tokenIsValid()
      refreshToken() if TokenService.tokenIsExpired()
      true
    else
      false

  loggedIn = isAuthenticated()

  login          : login
  logout         : logout
  isLoggedIn     : isLoggedIn
  isAuthenticated: isAuthenticated
  exchangeToken  : exchangeToken
  refreshToken   : refreshToken

AuthService.$inject = [
 '$rootScope'
 'AuthorizationsAPIService'
 'auth'
 'store'
 'TokenService'
]

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
