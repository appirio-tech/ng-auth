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
    request = AuthorizationsAPIService.remove().$promise
    request.then (response, status, headers, config) ->
      auth.signout()
      TokenService.deleteToken()
      $rootScope.$broadcast 'logout'

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

    onSuccess = (profile, idToken, accessToken, state, refreshToken) ->
      exchangeToken idToken, refreshToken, options.success

    # First remove any old tokens
    TokenService.deleteToken()

    store.set 'login-state', options.state if options.state

    auth.signin params, onSuccess, onError

  exchangeToken = (idToken, refreshToken, success, error) ->
    onSuccess = (res) ->
      TokenService.setToken res.result.content.token

      $rootScope.$broadcast 'authenticated' # **

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
      $rootScope.$broadcast 'logout'

    resource = AuthorizationsAPIService.get(id: 1).$promise

    resource.then onSuccess

    resource.catch onError

  isAuthenticated = ->
    if TokenService.tokenIsValid()
      true
    else if TokenService.tokenIsExpired()
      refreshToken()
      true
    else
      false

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
