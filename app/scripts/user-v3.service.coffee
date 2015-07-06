'use strict'

srv = (UserV3APIService, TokenService, AuthService, $rootScope) ->
  currentUser = null

  loadUser = (callback = null) ->
    decodedToken = TokenService.decodeToken()

    if decodedToken.userId
      params =
        id: decodedToken.userId

      resource = UserV3APIService.get params

      resource.$promise.then (response) ->
        currentUser = response

      resource.$promise.catch ->

      resource.$promise.finally ->

  getCurrentUser = ->
    currentUser

  # Create a User
  # @param options - array with the following properties
  # - handle
  # - password
  # - email
  # - firstname
  # - lastname
  # - utmSource
  # - utmMedium
  # - utmCampaign
  createUser = (options, callback, onError) ->
    if options.handle && options.email && options.password
      userParams =
        params:
          handle     : options.handle
          email      : options.email
          utmSource  : options.utmSource || 'asp'
          utmMedium  : options.utmMedium || ''
          utmCampaign: options.utmCampaign || ''
          # firstName  : options.firstname || ''
          # lastName   : options.lastname || ''
          credential :
            password: options.password

      resource = UserV3APIService.post userParams

      resource.$promise.then (response) ->
        callback? response

      resource.$promise.catch (response) ->
        onError? response

      resource.$promise.finally (response) ->

  $rootScope.$watch AuthService.isLoggedIn, ->
    currentUser = null
    loadUser() if AuthService.isLoggedIn()

  loadUser() if AuthService.isAuthenticated()

  getCurrentUser: getCurrentUser
  createUser    : createUser

srv.$inject = ['UserV3APIService', 'TokenService', 'AuthService', '$rootScope']

angular.module('appirio-tech-ng-auth').factory 'UserV3Service', srv
