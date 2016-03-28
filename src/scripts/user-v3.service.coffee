'use strict'

includes = require 'lodash/includes'

srv = (UserV3APIService, profilesAPIService, TokenService, AuthService, $rootScope, $q) ->
  currentUser = null

  loadUser = ->
    decodedToken = TokenService.decodeToken()

    if decodedToken.userId
      params =
        id: decodedToken.userId

      resource = profilesAPIService.get params

      resource.$promise.then (response) ->
        currentUser      = response
        currentUser.id   = currentUser.userId
        currentUser.role = 'customer'
        currentUser.role = 'copilot' if currentUser.isCopilot
        currentUser.role = 'admin' if includes decodedToken.roles, 'Connect Support'

        currentUser
    else
      $q.reject()

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
          firstName  : options.firstName || ''
          lastName   : options.lastName || ''
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
  loadUser      : loadUser

srv.$inject = ['UserV3APIService', 'profilesAPIService', 'TokenService', 'AuthService', '$rootScope', '$q']

angular.module('appirio-tech-ng-auth').factory 'UserV3Service', srv
