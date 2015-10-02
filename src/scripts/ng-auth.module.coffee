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

  jwtInterceptor = (TokenService, $http, API_URL) ->
    currentToken = TokenService.getToken()

    handleRefreshResponse = (res) ->
      newToken = res.data?.result?.content?.token

      TokenService.setToken newToken

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

        refreshingToken = $http(config).then(handleRefreshResponse).finally(refreshingTokenComplete)

      refreshingToken
    else
      currentToken

  jwtInterceptor.$inject = ['TokenService', '$http', 'API_URL']

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