import { GET_TOKEN_REQUEST, GET_TOKEN_SUCCESS, GET_TOKEN_FAILURE } from '../constants.js'
import iframe from './iframe.js'

let loading = new Promise(function(resolve, reject) {
  iframe.onload = function() {
    loading = false
    resolve()
  }
})

export const getToken = function (credentials) {
  function tokenRequest() {
    return new Promise( function(resolve, reject) {
      function success(e) {
        resolve()
      }

      function failure(e) {
        reject()
      }

      function receiveMessage(e) {
        console.log('host event', e)

        if (e.data.type === GET_TOKEN_SUCCESS) success(e.data)
        if (e.data.type === GET_TOKEN_FAILURE) failure(e.data)
      }

      window.addEventListener("message", receiveMessage)

      iframe.contentWindow.postMessage({
        type: GET_TOKEN_REQUEST
      }, 'http://localhost:8000')
    })
  }

  if (loading) {
    return loading = loading.then(tokenRequest)
  } else {
    return tokenRequest()
  }
}
