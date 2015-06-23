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

  getCurrentUser: getCurrentUser

srv.$inject = ['UserV3APIService', 'TokenService']

angular.module('appirio-tech-ng-auth').factory 'UserV3Service', srv
