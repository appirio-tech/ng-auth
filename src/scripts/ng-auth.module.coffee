'use strict'

{ TC_JWT } = require './constants'
{ isLoggedIn, ensureFreshToken } = require './auth.js'
{ decodeToken, isTokenExpired } = require './token.js'

dependencies = [
  'angular-jwt'
]

config = (
  $httpProvider
  jwtInterceptorProvider
) ->
  jwtInterceptor = () ->
    ensureFreshToken()

  jwtInterceptorProvider.tokenGetter = jwtInterceptor

  $httpProvider.interceptors.push 'jwtInterceptor'

config.$inject = [
  '$httpProvider'
  'jwtInterceptorProvider'
]

angular.module('appirio-tech-ng-auth', dependencies).config(config)