'use strict'

NgAuthController = (AuthService, SubmitWorkAPIService) ->
  vm              = this
  vm.message      = ''

  vm.login = ->
    onSuccess = ->
      vm.message = 'login done'

    params =
      username: 'happyTurtle'
      password: 'eatingAFlower'

    AuthService.login params

  vm.logout = ->
    AuthService.logout()

    vm.message = 'logout done'

  vm.isLoggedIn = ->
    vm.message = AuthService.isLoggedIn()

  vm.workApi = ->
    resource = SubmitWorkAPIService.get id: 123

    resource.$promise.then (response) ->
      vm.message = response

  activate = ->
    vm

  activate()

NgAuthController.$inject = ['AuthService', 'SubmitWorkAPIService']

angular.module('example').controller 'NgAuthController', NgAuthController
