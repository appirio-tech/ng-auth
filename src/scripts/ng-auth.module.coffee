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
  jwtInterceptor = (TokenService) ->
    TokenService.getToken()

  jwtInterceptor.$inject = ['TokenService']

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

run = (
  $rootScope
  $injector
  $state
  auth
  TokenService
  AuthService
) ->

  auth.hookEvents()

  checkRedirect = ->
    isProtected = !toState.data || (toState.data && !toState.data.noAuthRequired)
    notLoggedIn = !AuthService.isAuthenticated()
    if isProtected && notLoggedIn
      $rootScope.preAuthState = toState.name
      event.preventDefault()
      $state.go 'login'

    # check if state requires auth
  checkAuth = (event, toState) ->
    isInvalidToken = TokenService.getToken() && !TokenService.tokenIsValid()
    if isInvalidToken
      AuthService.refreshToken().then ->
        checkRedirect()
    else
      checkRedirect()

    $rootScope.$on '$stateChangeStart', checkAuth

config.$inject = [
  '$httpProvider'
  'jwtInterceptorProvider'
  'authProvider'
  'AUTH0_DOMAIN'
  'AUTH0_CLIENT_ID'
]

run.$inject = [
  '$rootScope'
  '$injector'
  '$state'
  'auth'
  'TokenService'
  'AuthService'
]

angular.module('appirio-tech-ng-auth', dependencies).config(config).run run