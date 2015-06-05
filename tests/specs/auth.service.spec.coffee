'use strict'

srv    = null
logout = null
stateGetStub = null
broadcastSpy = null
logout = null
wasCalledWith = null
exchangeTokenSpy = null

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

  # describe.only 'login method', ->
  #   beforeEach inject (store) ->
  #     exchangeTokenSpy = sinon.spy AuthService 'exchangeToken'
  #     srv.login()
  #     #$httpBackend.flush()

  #   afterEach ->
  #     exchangeTokenSpy.restore()

  #   it 'should have called exchangeToken', ->
  #     wasCalledWith = exchangeTokenSpy.calledWith 'idToken, refreshToken, options.success'
  #     expect(wasCalledWith).to.be.ok

  describe 'exchangeToken method', ->
    beforeEach inject (store, $rootScope, $httpBackend) ->
      broadcastSpy = sinon.spy $rootScope, '$broadcast'
      srv.exchangeToken()
      $httpBackend.flush()

    afterEach ->
      broadcastSpy.restore()

    it 'should have called $rootScope.$broadcast', ->
      wasCalledWith = broadcastSpy.calledWith 'authenticated'
      expect(wasCalledWith).to.be.ok


