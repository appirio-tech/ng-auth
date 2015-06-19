'use strict'

srv = (UserV3APIService, TokenService) ->
  getCurrentUser = (setUser) ->
    decodedToken = TokenService.decodedToken

    if decodedToken.userId.length
      resource = UserV3APIService.get decodedToken.userId

      resource.$promise.then (response) ->
        response.result.content #  or wherever the user is stored in
      resource.$promise.catch ->

      resource.$promise.finally ->

srv.$inject = ['UserV3APIService']

angular.module('appirio-tech-ng-auth').factory 'UserV3Service', srv