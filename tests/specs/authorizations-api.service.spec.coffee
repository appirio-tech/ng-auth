'use strict'

srv    = null
result = null

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
        result = response.result

      $httpBackend.flush()

    it 'should have at some results', ->
      expect(result.content[0].token).to.be.equal "abc"

  describe 'new authorization', ->
    beforeEach inject ($httpBackend) ->
      params =
        param:
          refreshToken: 'abc'
          externalToken: '123'

      newAuth = new srv params
      newAuth.$save (response) ->
        result = response.result

      $httpBackend.flush()

    it 'should have some results', ->
      expect(result.content[0].token).to.be.equal "abc"

  describe 'remove authorization', ->
    beforeEach inject ($httpBackend) ->
      srv.remove (response) ->
        result = response.result

      $httpBackend.flush()

    it 'should have at some results', ->
      expect(result.content[0].token).to.be.equal "abc"

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


