'use strict'

srv    = null
result = null

describe 'Token Service', ->
  beforeEach inject (TokenService) ->
    srv = TokenService

  it 'should have a getToken method', ->
    expect(srv.getToken).to.be.ok

  it 'should have a deleteToken method', ->
    expect(srv.deleteToken).to.be.ok

  it 'should have a decodeToken method', ->
    expect(srv.decodeToken).to.be.ok

  it 'should have a setToken method', ->
    expect(srv.setToken).to.be.ok

  it 'should have a tokenIsValid method', ->
    expect(srv.tokenIsValid).to.be.ok
