'use strict'

srv        = null
stubToken  = null
user       = null
createUser = null
userData   = null
success    = null

describe 'UserV3 Service', ->
  beforeEach inject (UserV3Service) ->
    srv = UserV3Service

  it 'should have a getCurrentUser method', ->
    expect(srv.getCurrentUser).to.be.ok

  it 'should have a createUser method', ->
    expect(srv.createUser).to.be.ok

  describe 'getCurrentUser method', ->
    beforeEach inject ($httpBackend, TokenService) ->
      stubToken = sinon.stub TokenService, 'decodeToken'

      stubToken.returns userId: '123'

      srv.getCurrentUser (response) ->
        user = response

      $httpBackend.flush()

    afterEach ->
      stubToken.restore()

    it 'should have some results', ->
      expect(user).to.be.ok

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
