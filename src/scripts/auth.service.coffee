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
<<<<<<< HEAD
    deferred = $q.defer()

    $http
=======
    config =
>>>>>>> master
      method: 'PUT'
      url: "#{API_URL}/v3/users/resetPassword"
      data:
        param:
          handle: handle
          credential:
            password: password
            resetToken: token

<<<<<<< HEAD
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
=======
    $http(config)

  login          : login
  logout         : logout
  isLoggedIn     : isLoggedIn
  sendResetEmail : sendResetEmail
  resetPassword  : resetPassword
>>>>>>> master

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
