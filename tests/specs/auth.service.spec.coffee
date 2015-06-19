'use strict'

srv    = null
logout = null
stateGetStub = null
broadcastSpy = null
logout = null
wasCalledWith = null
exchangeTokenSpy = null
setTokenSpy = null
getSpy = null
newToken = 'yyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS50b3Bjb2Rlci1kZXYuY29tIiwiZXhwIjoxNDMzMjcxNzYwLCJ1c2VySWQiOiI0MDEzNTUxNiIsImlhdCI6MTQzMzI3MTE2MCwianRpIjoiMDZhNzVjM2EtMTQ0MC00MWE3LTk5N2YtZmFmMGVjZjFmOGM1In0.okSjl5KOmGQ6hJEoQxk4SVkFra65_Id6KUQGdAVmJNe'
stateGetStub = null
checkRedirectSpy = null

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
    beforeEach inject ($rootScope, $httpBackend) ->
      broadcastSpy = sinon.spy $rootScope, '$broadcast'
      srv.logout()
      $httpBackend.flush()

    afterEach ->
      broadcastSpy.restore()

    it 'should have called $rootScope.$broadcast', ->
      wasCalledWith = broadcastSpy.calledWith 'logout'
      expect(wasCalledWith).to.be.ok

  # describe 'login method', ->
  #   beforeEach inject ($httpBackend) ->
  #     exchangeTokenSpy = sinon.spy srv, 'exchangeToken'
  #     srv.login()
  #     $httpBackend.flush()

  #   afterEach ->
  #     exchangeTokenSpy.restore()

  #   it 'should have called exchangeToken', ->
  #     wasCalledWith = exchangeTokenSpy.called
  #     expect(wasCalledWith).to.be.ok

  describe 'exchangeToken method', ->
    beforeEach inject ($rootScope, $httpBackend) ->
      broadcastSpy = sinon.spy $rootScope, '$broadcast'
      srv.exchangeToken()
      $httpBackend.flush()

    afterEach ->
      broadcastSpy.restore()

    it 'should have called $rootScope.$broadcast', ->
      wasCalledWith = broadcastSpy.calledWith 'authenticated'
      expect(wasCalledWith).to.be.ok

  describe 'refreshToken method', ->
    beforeEach inject ($httpBackend, TokenService) ->
      setTokenSpy  = sinon.spy TokenService, 'setToken'
      srv.refreshToken()
      $httpBackend.flush()

    afterEach ->
      setTokenSpy.restore()

    it 'should have called TokenService.setToken', ->
      wasCalledWith = setTokenSpy.called
      expect(wasCalledWith).to.be.ok

# describe 'checkRedirect method', ->
#   context 'when isInvalidToken is false'
#     beforeEach inject ($httpBackend) ->
#       checkRedirectSpy = sinon.spy 
      #don't know how to call a function  that's not inside an object



