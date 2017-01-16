'use strict'

AuthService = (
  AuthorizationsAPIService
  TokenService
  $q
  API_URL
  AUTH0_DOMAIN
  AUTH0_CLIENT_ID
  $http
) ->
  isLoggedIn = ->
    TokenService.tokenIsValid()

  logout = ->
    TokenService.deleteAllTokens()

    # Return a promise here for API consistency
    $q.when(true)

  auth0Signin = (options) ->
    config =
      method: 'POST'
      url: "https://#{AUTH0_DOMAIN}/oauth/ro"
      data:
        username      : options.username
        password      : options.password
        client_id     : AUTH0_CLIENT_ID
        sso           : false
        scope         : 'openid profile offline_access'
        response_type : 'token'
        connection    : options.connection || 'TC-User-Database'
        grant_type    : 'password'
        device        : 'Browser'

    $http(config)

  setAuth0Tokens = (res) ->
    TokenService.setAuth0Token res.data.id_token
    TokenService.setAuth0RefreshToken res.data.fresh_token

  getNewJWT = ->
    params =
      param:
        refreshToken: TokenService.getAuth0RefreshToken()
        externalToken: TokenService.getAuth0Token()

    newAuth = new AuthorizationsAPIService params

    newAuth.$save().then (res) ->
      res.result?.content?.token

  setJWT = (JWT) ->
    TokenService.setAppirioJWT JWT

  login = (options) ->
    success = options.success || angular.noop
    error = options.error || angular.noop

    auth0Signin(options)
      .then(setAuth0Tokens)
      .then(getNewJWT)
      .then(setJWT)
      .then(success)
      .catch(error)

  sendResetEmail = (email) ->
    $http
      method: 'GET'
      url: "#{API_URL}/v3/users/resetToken?email=#{email}&source=connect"

  resetPassword = (handle, token, password) ->
    config =
      method: 'PUT'
      url: "#{API_URL}/v3/users/resetPassword"
      data:
        param:
          handle: handle
          credential:
            password: password
            resetToken: token

    $http(config)

  login          : login
  logout         : logout
  isLoggedIn     : isLoggedIn
  sendResetEmail : sendResetEmail
  resetPassword  : resetPassword

AuthService.$inject = [
  'AuthorizationsAPIService'
  'TokenService'
  '$q'
  'API_URL'
  'AUTH0_DOMAIN'
  'AUTH0_CLIENT_ID'
  '$http'
]

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
