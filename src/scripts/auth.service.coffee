'use strict'

replace = require 'lodash/replace'

AuthService = (
  AuthorizationsAPIService
  TokenService
  $log
  $q
  $cookies
  API_URL
  AUTH0_DOMAIN
  AUTH0_CLIENT_ID
  $http
) ->
  
  isLoggedIn = ->
    TokenService.tokenIsValid()
  
  logout = ->
    jwt = TokenService.getAppirioJWT() || ''
    TokenService.deleteAllTokens()
    
    config =
      method: 'DELETE'
      url: "#{API_URL}/v3/authorizations/1"
      headers:
        'Authorization': 'Bearer ' + jwt
        
    $http(config)
      .catch (error) ->
        $log.error(error)

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
        connection    : options.connection || 'LDAP'
        grant_type    : 'password'
        device        : 'Browser'

    $http(config)

  setAuth0Tokens = (res) ->
    TokenService.setAuth0Token res?.data?.id_token
    TokenService.setAuth0RefreshToken res?.data?.refresh_token

  getNewJWT = ->
    params =
      param:
        refreshToken: TokenService.getAuth0RefreshToken()
        externalToken: TokenService.getAuth0Token()
    
    # Fix for: 
    # https://app.asana.com/0/100297043256537/100297043256590
    # To handle cookie in API call properly, XHR needs "withCredentials" option (true)
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS#Requests_with_credentials 
    # TODO:
    # This should be fixed in AuthorizationsAPIService.
    config =
      method: 'POST'
      url: "#{API_URL}/v3/authorizations"
      withCredentials: true,
      data: params

    success = (res) ->
      res.data?.result?.content?.token

    $http(config).then (success)

  setJWT = (JWT) ->
    TokenService.setAppirioJWT JWT
    
  setSSOToken = ->
    tcsso = $cookies.get('tcsso') || ''
    TokenService.setSSOToken tcsso

  login = (options) ->
    success = options.success || angular.noop
    error = options.error || angular.noop

    auth0Signin(options)
      .then(setAuth0Tokens)
      .then(getNewJWT)
      .then(setJWT)
      .then(setSSOToken)
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
    apiUrl = replace API_URL, 'api-work', 'api'

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
  '$log'
  '$q'
  '$cookies'
  'API_URL'
  'AUTH0_DOMAIN'
  'AUTH0_CLIENT_ID'
  '$http'
]

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
