'use strict'

srv = ($resource, API_URL) ->
  url     = API_URL + '/authorizations/:id'
  params  = id: '@id'

  $resource url, params

srv.$inject = ['$resource', 'API_URL']

angular.module('appirio-tech-ng-auth').factory 'AuthorizationsAPIService', srv
