'use strict'

NgAuthController = (AuthService, TokenService, SubmitWorkAPIService) ->
  vm              = this
  vm.message      = ''
  vm.token        = ''
  vm.aRefreshToken = ''

  getTokens = ->
    vm.token         = TokenService.getAppirioJWT()
    vm.aRefreshToken = TokenService.getAuth0RefreshToken()

  vm.login = ->
    onSuccess = ->
      vm.message = 'login done'

      getTokens()

    params =
      username: 'happyTurtle'
      password: 'eatingAFlower'
      success: onSuccess

    AuthService.login params

  vm.logout = ->
    AuthService.logout()

    vm.message = 'logout done'

    getTokens()

  vm.isLoggedIn = ->
    vm.message = AuthService.isLoggedIn()

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
