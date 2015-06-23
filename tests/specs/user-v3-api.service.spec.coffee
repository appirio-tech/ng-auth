'use strict'

srv    = null
result = null

describe 'UserV3APIService', ->
  beforeEach inject (UserV3APIService) ->
    srv = UserV3APIService

  it 'should have a get method', ->
    expect(srv.get).to.be.ok

  describe 'get user method', ->
    beforeEach inject ($httpBackend) ->
      params =
        id: '123'

      srv.get(params).$promise.then (response) ->
        result = response

      $httpBackend.flush()

    it 'should have some results', ->
      expect(result).to.be.ok
