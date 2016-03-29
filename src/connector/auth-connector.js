import { LOGIN_REQUEST, LOGIN_SUCCESS, LOGIN_FAILURE } from './constants.js'

const iframe = document.createElement('iframe')
iframe.src = 'https://accounts.topcoder.com/auth'
document.body.appendChild(iframe)

export const login = function (credentials) {
  return new Promise( function(resolve, reject) {
    function success(e) {
      resolve()
    }

    function failure(e) {
      reject()
    }

    function receiveMessage(e) {
      if (e.data.status === LOGIN_SUCCESS) success(e.data)
      if (e.data.status === LOGIN_FAILURE) failure(e.data)
    }

    window.addEventListener("message", receiveMessage)

    iframe.postMessage({
      type: LOGIN,
      credentials
    })
  })
}