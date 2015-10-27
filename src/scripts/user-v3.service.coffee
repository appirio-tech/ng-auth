'use strict'

srv = (UserV3APIService, profilesAPIService, TokenService, AuthService, $rootScope) ->
  currentUser = null

  loadUser = (callback = null) ->
    decodedToken = TokenService.decodeToken()

    if decodedToken.userId
      params =
        id: decodedToken.userId

      resource = profilesAPIService.get params

      resource.$promise.then (response) ->
        currentUser = response

      resource.$promise.catch ->

      resource.$promise.finally ->

  # This method should be very high performance since many things will be watching it.
  getCurrentUser = ->
    currentUser

  createUser = (options, callback, onError) ->
    if options.handle && options.email && options.password
      userParams =
        param:
          handle     : options.handle
          email      : options.email
          utmSource  : options.utmSource || 'asp'
          utmMedium  : options.utmMedium || ''
          utmCampaign: options.utmCampaign || ''
          firstName  : options.firstname || ''
          lastName   : options.lastname || ''
          credential :
            password: options.password

      if options.afterActivationURL
        userParams.options =
          afterActivationURL: options.afterActivationURL

      resource = UserV3APIService.post userParams

      resource.$promise.then (response) ->
        callback? response

      resource.$promise.catch (response) ->
        onError? response

      resource.$promise.finally (response) ->

  $rootScope.$watch AuthService.isLoggedIn, ->
    currentUser = null
    loadUser() if AuthService.isLoggedIn()

  getCurrentUser: getCurrentUser
  createUser    : createUser

srv.$inject = ['UserV3APIService', 'profilesAPIService', 'TokenService', 'AuthService', '$rootScope']

angular.module('appirio-tech-ng-auth').factory 'UserV3Service', srv
