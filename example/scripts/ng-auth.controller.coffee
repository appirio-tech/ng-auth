'use strict'

NgAuthController = (AuthService) ->
  vm = this
  vm.message = 'Click a button!'

  vm.login = ->
    onSuccess = ->
      vm.message = 'Login Success'

    params =
      username: 'happyTurtle'
      password: 'eatingAFlower'
      success: onSuccess

    AuthService.login params

  activate = ->
    vm

  activate()

NgAuthController.$inject = ['AuthService']

angular.module('example').controller 'NgAuthController', NgAuthController
