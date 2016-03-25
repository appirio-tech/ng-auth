'use strict'

{ login, logout, isLoggedIn, sendResetEmail, resetPassword, generateSSOUrl, getSSOProvider, getNewJWT } = require './auth.js'

AuthService = ->
  login            : login
  logout           : logout
  isLoggedIn       : isLoggedIn
  sendResetEmail   : sendResetEmail
  resetPassword    : resetPassword
  generateSSOUrl   : generateSSOUrl
  getSSOProvider   : getSSOProvider
  getNewJWT        : getNewJWT

angular.module('appirio-tech-ng-auth').factory 'AuthService', AuthService
