'use strict'

dependencies = [
  'app.constants'
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
  # Initialize Auth0
  authProvider.init
    domain    : AUTH0_DOMAIN
    clientID  : AUTH0_CLIENT_ID
    loginState: 'login'

  # Setup our JWT Interceptor
  refreshingToken = null

  jwtInterceptor = (TokenService, AuthService) ->
    refreshingTokenComplete = ->
      refreshingToken = null

    if TokenService.tokenIsValid() && TokenService.tokenIsExpired()
      if refreshingToken == null
        refreshingToken = AuthService.refreshAppirioJWT().finally(refreshingTokenComplete)

      refreshingToken
    else
      TokenService.getAppirioJWT()

  jwtInterceptor.$inject = ['TokenService', 'AuthService']

  jwtInterceptorProvider.tokenGetter = jwtInterceptor

  $httpProvider.interceptors.push 'jwtInterceptor'

run = (auth, $rootScope, AuthService) ->
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
  '$rootScope'
  'AuthService'
]

angular.module('appirio-tech-ng-auth', dependencies).config(config).run run