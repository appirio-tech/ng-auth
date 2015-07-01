'use strict'

srv            = null
stubToken      = null
user           = null
createUser     = null
userData       = null
success        = null
isLoggedInStub = null
decodeTokenSpy = null
currentUser    = null

describe 'UserV3 Service', ->
  beforeEach inject (UserV3Service) ->
    srv = UserV3Service

  it 'should have a getCurrentUser method', ->
    expect(srv.getCurrentUser).to.be.ok

  it 'should have a createUser method', ->
    expect(srv.createUser).to.be.ok

  describe 'loadUser if AuthService.isLoggedIn', ->
    beforeEach inject (AuthService, $rootScope, TokenService) ->
      isLoggedInStub = sinon.stub(AuthService, 'isLoggedIn').returns true
      decodeTokenSpy = sinon.spy TokenService, 'decodeToken'
      $rootScope.$digest()

    afterEach ->
      isLoggedInStub.restore()
      decodeTokenSpy.restore()

    it 'should call loadUser method when AuthService.isLoggedIn', ->
      wasCalled = decodeTokenSpy.calledOnce
      expect(wasCalled).to.be.ok

  describe 'createUser method', ->
    beforeEach inject ($httpBackend) ->
      userData =
        handle     : 'Batman'
        password   : 'secret'
        email      : 'promero@appirio.com'
        firstName  : 'batman'
        lastName   : 'potter'
        utmSource  : 'asp'
        utmMedium  : ''
        utmCampaign: ''

      srv.createUser userData, (response) ->
        success = response

      $httpBackend.flush()

    it 'should have have been successful', ->
      expect(success).to.be.ok
