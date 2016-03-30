import { GET_TOKEN_REQUEST, GET_TOKEN_SUCCESS, GET_TOKEN_FAILURE } from '../constants.js'
import { TC_JWT } from '../constants.js'
import { getToken } from '../auth.js'

localStorage.setItem(TC_JWT, 'abc')

window.addEventListener('message', function(e) {
  console.log('iframe event', e)

  function success(token) {
    e.source.postMessage({
      type: 'GET_TOKEN_SUCCESS',
      token
    }, e.origin)
  }

  function failure(data) {
    e.source.postMessage({
      type: 'GET_TOKEN_FAILURE'
    }, e.origin)
  }

  if (e.data.type === 'GET_TOKEN_REQUEST') {
    const token = getToken()

    if (token) {
      success(token)
    } else {
      failure()
    }
  }
})