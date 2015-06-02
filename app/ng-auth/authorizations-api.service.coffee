'use strict'

transformResponse = (response) ->
  parsed = JSON.parse response

  parsed?.result?.content || []

srv = ($resource, apiUrl) ->
  url     = apiUrl + 'authorizations/:id'
  params  = id: '@id'
  actions =
    update:
      method           : 'PUT'
      isArray          : true
      transformResponse: transformResponse

  $resource url, params, actions

srv.$inject = ['$resource', 'apiUrl']

angular.module('appirio-tech-ng-auth').factory 'AuthorizationsAPIService', srv
