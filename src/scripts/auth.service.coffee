'use strict'

AuthService = (
  AuthorizationsAPIService
  auth
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

  # TODO: Replace this method with a straight $http/$resource call
  # TODO: Remove the auth0 library
  auth0Signin = (options) ->
    deferred = $q.defer()

    defaultOptions =
      retUrl: '/'

    lOptions = angular.extend {}, options, defaultOptions

    params =
      username  : lOptions.username
      password  : lOptions.password
      sso       : false
      connection: 'LDAP'
      authParams:
        scope: 'openid profile offline_access'

    signinError = (err) ->
      deferred.reject(err)

    signinSuccess = (profile, idToken, accessToken, state, refreshToken) ->
      deferred.resolve
        identity: idToken
        refresh: refreshToken

    auth.signin params, signinSuccess, signinError

    deferred.promise

  setAuth0Tokens = (tokens) ->
    TokenService.setAuth0Token tokens.identity
    TokenService.setAuth0RefreshToken tokens.refresh

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
    deferred = $q.defer()

    $http
      method: 'PUT'
      url: "#{API_URL}/v3/users/resetPassword"
      data:
        param:
          handle: handle
          credential:
            password: password
            resetToken: token

  generateSSOUrl = (org, callbackUrl) ->
    [
      "https://#{AUTH0_DOMAIN}/authorize?"
      "response_type=token"
      "&client_id=#{AUTH0_CLIENT_ID}"
      "&connection=#{org}"
      "&redirect_uri=#{API_URL}/pub/callback.html"
      "&state=#{encodeURIComponent(callbackUrl)}"
      "&scope=openid%20profile%20offline_access"
      "&device=device"
    ].join('')

  getSSOProvider = (emailOrHandle) ->
    deferred = $q.defer()

    data =
      param: {}

    if emailOrHandle.indexOf('@') > -1
      data.param.email = emailOrHandle
    else
      data.param.handle = emailOrHandle

    success = (res) ->
      org = res.data?.result?.org

      if org
        deferred.resolve res.data.result.org
      else
        deferred.reject 'Could not find an SSO organization for that user'

    failure = (res) ->
      err = res.data?.result?.content || 'Something went wrong'

      deferred.reject err

    config = 
      method: 'GET'
      url: "#{API_URL}/v3/users/resetPassword"
      data: data

    $http(config).then(success).catch(failure)

    deferred.promise

  login            : login
  logout           : logout
  isLoggedIn       : isLoggedIn
  sendResetEmail   : sendResetEmail
  resetPassword    : resetPassword
  generateSSOUrl   : generateSSOUrl
  getSSOProvider   : getSSOProvider

AuthService.$inject = [
  'AuthorizationsAPIService'
  'auth'
  'TokenService'
  '$q'
  'API_URL'
  'AUTH0_DOMAIN'
  'AUTH0_CLIENT_ID'
  '$http'
]

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
