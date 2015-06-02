'use strict'

AuthService = (
  $rootScope
  AuthorizationsAPIService
  auth
  store
  TokenService
  $state
) ->
  logout = ->
    logoutComplete = (response, status, headers, config) ->
      auth.signout()
      TokenService.deleteToken()
      $rootScope.$broadcast 'logout'

    AuthorizationsAPIService.remove().then(logoutComplete).catch (message) ->
      $state.reload()

  login = (options) ->
    # First remove any old tokens
    TokenService.deleteToken()

    defaultOptions =
      retUrl: '/'

    lOptions = angular.extend {}, options, defaultOptions

    if options.state
      store.set 'login-state', options.state

    params =
      username  : lOptions.username
      password  : lOptions.password
      sso       : false
      connection: 'LDAP'
      authParams:
        scope: 'openid profile offline_access'

    auth.signin params, onSuccess, onError

    onError = (err) ->
      options.error err

    onSuccess = (profile, idToken, accessToken, state, refreshToken) ->
      exchangeToken idToken, refreshToken, options.success

  exchangeToken = (idToken, refreshToken, success, error) ->
    onSuccess = (res) ->
      TokenService.setToken res.result.content.token

      $rootScope.$broadcast 'authenticated'

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
      $rootScope.$broadcast 'authenticated'

    onError = (response) ->
      TokenService.deleteToken()

    AuthorizationsAPIService.get(id: 1).then onSuccess, onError

  isAuthenticated = ->
    TokenService.tokenIsValid()

  login          : login
  logout         : logout
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
