'use strict'

srv    = null
token  = null
logout = null

describe 'AuthorizationsAPIService', ->
  beforeEach inject (AuthorizationsAPIService) ->
    srv = AuthorizationsAPIService

  it 'should have a get method', ->
    expect(srv.get).to.be.ok

  it 'should have a remove method', ->
    expect(srv.remove).to.be.ok

  describe 'get authorization', ->
    beforeEach inject ($httpBackend) ->
      params =
        id: '123'

      srv.get params, (response) ->
        token = response.result.content.token

      $httpBackend.flush()

    it 'should have at some results', ->
      expect(token).to.be.ok
