'use strict'

replace = require 'lodash/replace'

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
        connection    : 'LDAP'
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

  generateSSOUrl = (org, callbackUrl) ->
    apiUrl = replace callbackUrl, 'api-work', 'api'

    [
      "https://#{AUTH0_DOMAIN}/authorize?"
      "response_type=token"
      "&client_id=#{AUTH0_CLIENT_ID}"
      "&connection=#{org}"
      "&redirect_uri=#{apiUrl}/pub/callback.html"
      "&state=#{encodeURIComponent(callbackUrl)}"
      "&scope=openid%20profile%20offline_access"
      "&device=device"
    ].join('')

  getSSOProvider = (handle) ->
    filter = encodeURIComponent "handle=#{ handle }"

    AuthException = (params) ->
      Object.assign this, { location: 'auth.service.coffee' }, params

    success = (res) ->
      content = res.data?.result?.content

      unless content
        throw new AuthException
          message: 'Could not contact login server'
          reason: 'Body did not contain content'
          response: res

      unless content.type == 'samlp'
        throw new AuthException
          message: 'This handle does not appear to have an SSO login associated'
          reason: 'No provider of type \'samlp\''
          response: res

      content.name

    failure = (res) ->
      throw new AuthException
        message: res.data?.result?.content || 'Could not contact login server'

    config = 
      method: 'GET'
      url: "#{ API_URL }/v3/identityproviders?filter=#{ filter }"

    $http(config).catch(failure).then(success)

  login            : login
  logout           : logout
  isLoggedIn       : isLoggedIn
  sendResetEmail   : sendResetEmail
  resetPassword    : resetPassword
  generateSSOUrl   : generateSSOUrl
  getSSOProvider   : getSSOProvider

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
