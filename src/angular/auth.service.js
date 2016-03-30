'use strict'

import { isLoggedIn } from '../auth.js'

const AuthService = function() {
  return {
    isLoggedIn: isLoggedIn,
  }
}

angular.module('appirio-tech-ng-auth').factory('AuthService', AuthService)
