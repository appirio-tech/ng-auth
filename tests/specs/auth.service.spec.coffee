'use strict'

srv    = null
logout = null
stateGetStub = null
broadcastSpy = null
logout = null
wasCalledWith = null

describe 'Authorization Service', ->
  beforeEach inject (AuthService) ->
    srv = AuthService

  it 'should have a logout method', ->
    expect(srv.logout).to.be.ok

  it 'should have a login method', ->
    expect(srv.login).to.be.ok

  it 'should have a exchangeToken method', ->
    expect(srv.exchangeToken).to.be.ok

  it 'should have a refreshToken method', ->
    expect(srv.refreshToken).to.be.ok

  it 'should have a isAuthenticated method', ->
    expect(srv.isAuthenticated).to.be.ok

  describe 'logout method', ->
    beforeEach inject (store, $rootScope, $httpBackend) ->
      broadcastSpy = sinon.spy $rootScope, '$broadcast'
      srv.logout()
      $httpBackend.flush()

    afterEach ->
      broadcastSpy.restore()

    it 'should have called $rootScope.$broadcast', ->
      wasCalledWith = broadcastSpy.calledWith 'logout'
      expect(wasCalledWith).to.be.ok


  # describe 'tokenIsValid method', ->
  #   context 'when token is not a string', ->
  #     beforeEach ->
  #       validToken = srv.tokenIsValid()

  #     it 'validToken should be false', ->
  #       expect(validToken).to.equal false

  #   context 'when token is `token`', ->
  #     beforeEach inject (store, jwtHelper) ->
  #       stateGetStub = sinon.stub(store, 'get').returns token
  #       isTokenExpiredSpy = sinon.spy jwtHelper, 'isTokenExpired'
  #       validToken = srv.tokenIsValid()

  #     afterEach ->
  #       stateGetStub.restore()
  #       isTokenExpiredSpy.restore()

  #     it 'should have called jwtHelper.isTokenExpired', ->
  #       wasCalledWith = isTokenExpiredSpy.calledWith token
  #       expect(wasCalledWith).to.be.ok