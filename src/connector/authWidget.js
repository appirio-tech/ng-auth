import { LOGIN_REQUEST, LOGIN_SUCCESS, LOGIN_FAILURE } from './constants.js'
import { login } from 'ourStandardLibraryOfAuthFunction.js'

window.addEventListener('message', function(e) {
  function success(data) {
    e.source.postMessage({
      type: LOGIN_SUCCESS
    })
  }

  function failure(data) {
    e.source.postMessage({
      type: LOGIN_FAILURE
    })
  }

  if (e.data.type === LOGIN_REQUEST) {
    login(e.data.credentials).then(success).catch(failure)
  }
})