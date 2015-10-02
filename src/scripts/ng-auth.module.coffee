'use strict'

dependencies = [
  'ngResource'
  'app.constants'
  'ui.router'
  'angular-storage'
  'angular-jwt'
  'auth0'
  'appirio-tech-ng-api-services'
]

config = (
  $httpProvider
  jwtInterceptorProvider
  authProvider
  AUTH0_DOMAIN
  AUTH0_CLIENT_ID
) ->
  refreshingToken = null

  jwtInterceptor = (TokenService, AuthService) ->
    refreshingTokenComplete = ->
      refreshingToken = null

    if TokenService.tokenIsValid()
      if TokenService.tokenIsExpired()
        if refreshingToken == null
          refreshingToken = AuthService.exchangeToken().finally(refreshingTokenComplete)

        refreshingToken
      else
        TokenService.getToken()
    else
      ''

  jwtInterceptor.$inject = ['TokenService', 'AuthService']

  jwtInterceptorProvider.tokenGetter = jwtInterceptor

  $httpProvider.interceptors.push 'jwtInterceptor'

  authProvider.init
    domain    : AUTH0_DOMAIN
    clientID  : AUTH0_CLIENT_ID
    loginState: 'login'

  logout = (TokenService) ->
    TokenService.deleteToken()

  logout.$inject = ['TokenService']

  authProvider.on 'logout', logout

run = (auth) ->
  auth.hookEvents()

config.$inject = [
  '$httpProvider'
  'jwtInterceptorProvider'
  'authProvider'
  'AUTH0_DOMAIN'
  'AUTH0_CLIENT_ID'
]

run.$inject = [
  'auth'
]

angular.module('appirio-tech-ng-auth', dependencies).config(config).run run