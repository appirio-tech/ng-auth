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

  jwtInterceptor = (TokenService, $http, API_URL) ->
    currentToken = TokenService.getAppirioJWT()

    handleRefreshResponse = (res) ->
      newToken = res.data?.result?.content?.token

      TokenService.setAppirioJWT newToken

      newToken

    refreshingTokenComplete = ->
      refreshingToken = null

    if TokenService.tokenIsValid() && TokenService.tokenIsExpired()
      if refreshingToken == null
        config =
          method: 'GET'
          url: "#{API_URL}/v3/authorizations/1"
          headers:
            'Authorization': "Bearer #{currentToken}"

        # IMPORTANT: This API call must be defined here in the config block
        # If you're thinking of refactoring, here be dragons!
        refreshingToken = $http(config).then(handleRefreshResponse).finally(refreshingTokenComplete)

      refreshingToken
    else
      currentToken

  jwtInterceptor.$inject = ['TokenService', '$http', 'API_URL']

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