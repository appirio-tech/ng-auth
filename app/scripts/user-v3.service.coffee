'use strict'

srv = (UserV3APIService, TokenService) ->
  getCurrentUser = (callback) ->
    decodedToken = TokenService.decodeToken()

    if decodedToken.userId
      params =
        id: decodedToken.userId

      resource = UserV3APIService.get params

      resource.$promise.then (response) ->
        callback? response

      resource.$promise.catch ->

      resource.$promise.finally ->

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
  createUser = (options, callback) ->
    if options.handle && options.email && options.password
      userParams =
        params:
          handle     : options.handle,
          email      : options.email,
          utmSource  : options.utmSource || 'asp',
          utmMedium  : options.utmMedium || '',
          utmCampaign: options.utmCampaign || '',
          firstName  : options.firstname,
          lastName   : options.lastname,
          credential :
            password: options.password

      resource = UserV3APIService.save userParams

      resource.$promise.then (response) ->
        callback? response

      resource.$promise.catch (response) ->
        console.log "catch" + response

      resource.$promise.finally (response) ->
        console.log "finally" + response

  getCurrentUser: getCurrentUser
  createUser: createUser

srv.$inject = ['UserV3APIService', 'TokenService']

angular.module('appirio-tech-ng-auth').factory 'UserV3Service', srv
