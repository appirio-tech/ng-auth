'use strict'

includes = require 'lodash/includes'
merge = require 'lodash/merge'

{ TC_JWT } = require './constants'
{ isLoggedIn, registerUser } = require './auth.js'
{ decodeToken } = require './token.js'

srv = (UserV3APIService, profilesAPIService, $rootScope, $q) ->
  currentUser = null

  loadUser = ->
    decodedToken = decodeToken( localStorage.getItem(TC_JWT) )

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

  createUser = (body) ->
    registerUser(body)

  $rootScope.$watch isLoggedIn, ->
    currentUser = null
    loadUser() if isLoggedIn()

  getCurrentUser: getCurrentUser
  createUser    : createUser
  loadUser      : loadUser

srv.$inject = ['UserV3APIService', 'profilesAPIService', '$rootScope', '$q']

angular.module('appirio-tech-ng-auth').factory 'UserV3Service', srv
