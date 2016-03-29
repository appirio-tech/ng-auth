'use strict'

require('angular')
require('angular-jwt')

import { TC_JWT } from '../constants'
import { isLoggedIn, ensureFreshToken } from '../auth.js'
import { decodeToken, isTokenExpired } from '../token.js'

const dependencies = ['angular-jwt']

const config = function($httpProvider, jwtInterceptorProvider) {
  function jwtInterceptor() {
    return ensureFreshToken()
  }

  jwtInterceptorProvider.tokenGetter = jwtInterceptor

  $httpProvider.interceptors.push('jwtInterceptor')
}

config.$inject = ['$httpProvider', 'jwtInterceptorProvider']

angular.module('appirio-tech-ng-auth', dependencies).config(config)

// These must come after the module definition
require('./auth.service.js')
require('./user-v3.service.js')