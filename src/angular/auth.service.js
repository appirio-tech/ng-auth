'use strict'

import { login, logout, sendResetEmail, resetPassword, generateSSOUrl, getSSOProvider, getNewJWT } from '../auth.js'
import { getToken } from '../connector/connector-wrapper.js'

const AuthService = function() {
  function isLoggedIn() {
    return getToken().then( (token) => {
      console.log(token)
    }, (err) => {
      console.log(err)
    })
  }

  return {
    login: login,
    logout: logout,
    isLoggedIn: isLoggedIn,
    sendResetEmail: sendResetEmail,
    resetPassword: resetPassword,
    generateSSOUrl: generateSSOUrl,
    getSSOProvider: getSSOProvider,
    getNewJWT: getNewJWT
  }
}

angular.module('appirio-tech-ng-auth').factory('AuthService', AuthService)
