'use strict'

NgAuthController = (AuthService, TokenService) ->
  vm            = this
  vm.message    = ''
  vm.token      = ''
  vm.resetToken = ''

  vm.login = ->
    onSuccess = ->
      vm.message = 'Login done'
      vm.token = TokenService.getToken()

    params =
      username: 'happyTurtle'
      password: 'eatingAFlower'
      success: onSuccess

    AuthService.login params

  vm.logout = ->
    AuthService.logout()

    vm.message = 'Logout done'
    vm.token = TokenService.getToken()

  vm.isLoggedIn = ->
    vm.message = AuthService.isLoggedIn()

  vm.isAuthenticated = ->
    vm.message = AuthService.isAuthenticated()

  activate = ->
    vm

  activate()

NgAuthController.$inject = ['AuthService', 'TokenService']

angular.module('example').controller 'NgAuthController', NgAuthController
