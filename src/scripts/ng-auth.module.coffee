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
        refreshingToken = AuthService.getNewToken().finally(refreshingTokenComplete)

      refreshingToken
    else
      TokenService.getToken()

  jwtInterceptor.$inject = ['TokenService', 'AuthService']

  jwtInterceptorProvider.tokenGetter = jwtInterceptor

  $httpProvider.interceptors.push 'jwtInterceptor'

run = (auth, $rootScope, AuthService) ->
  auth.hookEvents()

  # On browser refresh, set logged in state based on valid JWT
  $rootScope.$on '$locationChangeStart', ->
    AuthService.setLoggedInFromStore()

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