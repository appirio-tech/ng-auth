'use strict'

srv            = null
deleteTokenSpy = null
wasCalled      = null
setTokenSpy    = null

describe 'Authorization Service', ->
  beforeEach inject (AuthService) ->
    srv = AuthService

  it 'should have a isLoggedIn method', ->
    expect(srv.isLoggedIn).to.be.ok

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
    beforeEach inject ($httpBackend, TokenService) ->
      deleteTokenSpy = sinon.spy TokenService, 'deleteToken'
      srv.logout()
      $httpBackend.flush()

    afterEach ->
      deleteTokenSpy.restore()

    it 'should have called TokenService.deleteToken', ->
      wasCalled = deleteTokenSpy.called
      expect(wasCalled).to.be.ok

  # describe 'login method', ->
  #   beforeEach inject (TokenService) ->
  #     deleteTokenSpy = sinon.spy TokenService, 'deleteToken'
  #     options =
  #       username: 'abc'
  #       password: '123'
  #       success : true
  #       state   : true

  #     srv.login(options)

  #   afterEach ->
  #     deleteTokenSpy.restore()

  #   it 'should have called TokenService.deleteToken', ->
  #     wasCalled = deleteTokenSpy.called
  #     expect(wasCalled).to.be.ok

  describe 'exchangeToken method', ->
    beforeEach inject ($httpBackend, TokenService) ->
      setTokenSpy  = sinon.spy TokenService, 'setToken'
      srv.exchangeToken()
      $httpBackend.flush()

    afterEach ->
      setTokenSpy.restore()

    it 'should have called TokenService.setToken', ->
      wasCalled = setTokenSpy.calledOnce
      expect(wasCalled).to.be.ok

  describe 'refreshToken method', ->
    beforeEach inject ($httpBackend, TokenService) ->
      setTokenSpy  = sinon.spy TokenService, 'setToken'
      srv.refreshToken()
      $httpBackend.flush()

    afterEach ->
      setTokenSpy.restore()

    it 'should have called TokenService.setToken', ->
      wasCalled = setTokenSpy.calledOnce
      expect(wasCalled).to.be.ok
