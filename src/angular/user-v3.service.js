'use strict'

import includes from 'lodash/includes'
import merge from 'lodash/merge'
import { TC_JWT } from '../constants'
import { isLoggedIn, registerUser} from '../auth.js'
import { decodeToken } from '../token.js'

const UserV3Service = function() {
  let currentUser = null

  const loadUser = function() {
    const decodedToken = decodeToken( localStorage.getItem(TC_JWT) )

    if (decodedToken.userId) {
      currentUser = decodedToken
      currentUser.id = currentUser.userId
      currentUser.role = 'customer'

      if (includes(decodedToken.roles, 'Connect Copilot')) {
        currentUser.role = 'copilot'
      }

      if (includes(decodedToken.roles, 'Connect Support')) {
        currentUser.role = 'admin'
      }

      return Promise.resolve(currentUser)
    } else {
      return Promise.reject()
    }
  }

  const getCurrentUser = function() {
    return currentUser
  }

  const createUser = function(body) {
    return registerUser(body)
  }

  return {
    getCurrentUser: getCurrentUser,
    createUser: createUser,
    loadUser: loadUser
  }
}

angular.module('appirio-tech-ng-auth').factory('UserV3Service', UserV3Service)