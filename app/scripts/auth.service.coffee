'use strict'

AuthService = (
  $rootScope
  AuthorizationsAPIService
  auth
  store
  TokenService
  $state
) ->
  loggedIn = false

  isLoggedIn = ->
    loggedIn

  logout = ->
    request = AuthorizationsAPIService.remove().$promise
    request.then (response, status, headers, config) ->
      auth.signout()
      TokenService.deleteToken()
      loggedIn = false

    request.catch (message) ->
      $state.reload()

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
      options.error err

    onSuccess = (idToken, refreshToken) ->
      exchangeToken idToken, refreshToken, options?.success

    # First remove any old tokens
    TokenService.deleteToken()

    store.set 'login-state', options.state if options?.state

    auth.signin params, onSuccess, onError

  exchangeToken = (idToken, refreshToken, success, error) ->
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

  refreshToken = ->
    onSuccess = (response) ->
      newToken = response.result.content.token

      TokenService.setToken newToken
      loggedIn = true

    onError = (response) ->
      TokenService.deleteToken()
      loggedIn = false

    resource = AuthorizationsAPIService.get(id: 1).$promise

    resource.then onSuccess

    resource.catch onError

  isAuthenticated = ->
    if TokenService.tokenIsValid()
     refreshToken() if TokenService.tokenIsExpired()
     true
    else
      false

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
 '$state'
]

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
