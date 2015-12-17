'use strict'

dependencies = [
  'app.constants'
  'angular-storage'
  'angular-jwt'
  'appirio-tech-ng-api-services'
]

config = (
  $httpProvider
  jwtInterceptorProvider
) ->
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

config.$inject = [
  '$httpProvider'
  'jwtInterceptorProvider'
]

angular.module('appirio-tech-ng-auth', dependencies).config(config)