'use strict'

config = ($stateProvider) ->
  states = {}

  states['ng-auth'] =
    url         : '/'
    title       : 'ngAuth'
    controller  : 'NgAuthController as vm'
    templateUrl : 'views/ng-auth.html'

  for key, state of states
    $stateProvider.state key, state

config.$inject = ['$stateProvider']

angular.module('example').config(config).run()


