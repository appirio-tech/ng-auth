'use strict'

NgAuthController = (AuthService, TokenService, SubmitWorkAPIService) ->
  vm              = this
  vm.message      = ''
  vm.token        = ''
  vm.aRefreshToken = ''

  getTokens = ->
    vm.token         = TokenService.getToken()
    vm.aRefreshToken = TokenService.getRefreshToken()

  vm.login = ->
    onSuccess = ->
      vm.message = 'login done'

      getTokens()

    params =
      username: 'happyTurtle'
      password: 'eatingAFlower'
      success: onSuccess

    AuthService.login params

  vm.refreshToken = ->
    onSuccess = ->
      vm.message = 'refreshToken done'

      getTokens()

    AuthService.refreshToken onSuccess

  vm.logout = ->
    AuthService.logout()

    vm.message = 'logout done'

    getTokens()

  vm.isLoggedIn = ->
    vm.message = AuthService.isLoggedIn()

  vm.isAuthenticated = ->
    vm.message = AuthService.isAuthenticated()

  vm.workApi = ->
    resource = SubmitWorkAPIService.get id: 123

    resource.$promise.then (response) ->
      vm.message = response

  activate = ->
    getTokens()

    vm

  activate()

NgAuthController.$inject = ['AuthService', 'TokenService', 'SubmitWorkAPIService']

angular.module('example').controller 'NgAuthController', NgAuthController
