'use strict'

srv       = null
stubToken = null
user      = null

describe 'UserV3 Service', ->
  beforeEach inject (UserV3Service) ->
    srv = UserV3Service

  it 'should have a getCurrentUser method', ->
    expect(srv.getCurrentUser).to.be.ok

  it 'should have a callback method', ->
    expect(srv.callback).to.be.ok

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
