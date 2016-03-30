import { GET_TOKEN_REQUEST, GET_TOKEN_SUCCESS, GET_TOKEN_FAILURE, REFRESH_TOKEN_REQUEST, REFRESH_TOKEN_SUCCESS, REFRESH_TOKEN_FAILURE } from '../constants.js'
import { TC_JWT } from '../constants.js'
import { getToken, refreshToken } from '../auth.js'

localStorage.setItem(TC_JWT, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6WyJUb3Bjb2RlciBVc2VyIl0sImlzcyI6Imh0dHBzOi8vYXBpLnRvcGNvZGVyLWRldi5jb20iLCJoYW5kbGUiOiJhbmRyZXdjdXN0b21lciIsImV4cCI6MTQ1OTM2MTY2OSwidXNlcklkIjoiNDAxNDEzMzYiLCJpYXQiOjE0NTkzNjEwNjksImVtYWlsIjoiYXNlbGJpZStjdXN0b21lckBnbWFpbC5jb20iLCJqdGkiOiIxNjZmMjkyOC0xNzNiLTRkMDEtOGU0Ny1kMjAxZGE4M2I1NzUifQ.RO2Pft1EmgFN_m8RqCZ0gNCtg1C9pUFsce0C0KKwQjk')

window.addEventListener('message', function(e) {
  if (e.data.type === GET_TOKEN_REQUEST) {
    console.log('iframe event', e.data)
    const token = getToken()

    if (token) {
      e.source.postMessage({
        type: GET_TOKEN_SUCCESS,
        token
      }, e.origin)
    } else {
      e.source.postMessage({
        type: GET_TOKEN_FAILURE
      }, e.origin)
    }
  }
})

window.addEventListener('message', function(e) {
  function success(token) {
    e.source.postMessage({
      type: REFRESH_TOKEN_SUCCESS,
      token
    }, e.origin)
  }

  function failure(error) {
    e.source.postMessage({
      type: REFRESH_TOKEN_FAILURE
    }, e.origin)
  }

  if (e.data.type === REFRESH_TOKEN_REQUEST) {
    console.log('iframe event', e.data)
    refreshToken().then(success, failure)
  }
})