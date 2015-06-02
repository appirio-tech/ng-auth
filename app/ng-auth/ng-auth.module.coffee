'use strict'

dependencies = [
  'angular-storage'
  'angular-jwt'
  'app.constants'
  'auth0'
]

config = (
  $httpProvider
  jwtInterceptorProvider
  authProvider
  auth0Domain
  auth0ClientId
) ->
  jwtInterceptor = (TokenService) ->
    TokenService.getToken()

  jwtInterceptor.$inject = ['TokenService']

  jwtInterceptorProvider.tokenGetter = jwtInterceptor

  $httpProvider.interceptors.push 'jwtInterceptor'

  authProvider.init
    domain    : auth0Domain
    clientID  : auth0ClientId
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

angular.module('appirio-tech-ng-auth', dependencies).config(config).run authRun