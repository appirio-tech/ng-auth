'use strict'

srv             = null
deleteAllTokensSpy  = null
wasCalled       = null
setTokenSpy     = null
tokenExpiredSpy = null
isAuthed        = null
refreshToken    = 'bDZX0e3VHrMZPvlpLaYCzKuJSP2SftW0bFGbpE3IbH1l0'
stateGetStub    = null

describe 'Authorization Service', ->
  beforeEach inject (AuthService) ->
    srv = AuthService

  it 'should have a isLoggedIn method', ->
    expect(srv.isLoggedIn).to.be.ok

  it 'should have a logout method', ->
    expect(srv.logout).to.be.ok

  describe 'login method', ->
    beforeEach inject (TokenService) ->

    it 'should exist', ->
      expect(srv.login).to.exist

  describe 'logout method', ->
    beforeEach inject (TokenService) ->
      deleteAllTokensSpy = sinon.spy TokenService, 'deleteAllTokens'
      srv.logout()

    afterEach ->
      deleteAllTokensSpy.restore()

    it 'should have called TokenService.deleteToken', ->
      wasCalled = deleteAllTokensSpy.called
      expect(wasCalled).to.be.ok
