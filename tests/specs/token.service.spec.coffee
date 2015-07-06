'use strict'

srv             = null
decodedToken    = null
decodeTokenSpy  = null
stateGetStub    = null
token           = 'yyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS50b3Bjb2Rlci1kZXYuY29tIiwiZXhwIjoxNDMzMjcxNzYwLCJ1c2VySWQiOiI0MDEzNTUxNiIsImlhdCI6MTQzMzI3MTE2MCwianRpIjoiMDZhNzVjM2EtMTQ0MC00MWE3LTk5N2YtZmFmMGVjZjFmOGM1In0.okSjl5KOmGQ6hJEoQxk4SVkFra65_Id6KUQGdAVmJNe'
validToken      = null
isExpired       = null
expiredTokenSpy = null

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

  it 'should have a tokenIsExpired method', ->
    expect(srv.tokenIsExpired).to.be.ok

  describe 'decodeToken method', ->
    context 'when token is null', ->
      beforeEach ->
        decodedToken = srv.decodeToken()

      it 'decodedToken to be ok', ->
        expect(decodedToken).to.be.ok

    context 'when token is `token`', ->
      beforeEach inject (store, jwtHelper) ->
        stateGetStub   = sinon.stub(store, 'get').returns token
        decodeTokenSpy = sinon.spy jwtHelper, 'decodeToken'
        decodedToken   = srv.decodeToken()

      afterEach ->
        stateGetStub.restore()
        decodeTokenSpy.restore()

      it 'should have called jwtHelper.decodeToken', ->
        wasCalledWith = decodeTokenSpy.calledWith token
        expect(wasCalledWith).to.be.ok

      it 'it should match userId: `40135516`', ->
        expect(decodedToken.userId).to.be.equal '40135516'

  describe 'tokenIsValid method', ->
    context 'when token is not a string', ->
      beforeEach ->
        validToken = srv.tokenIsValid()

      it 'validToken should be false', ->
        expect(validToken).to.equal false

  describe 'tokenIsExpired method', ->
    context 'when token is not a string', ->
      beforeEach ->
        isExpired = srv.tokenIsExpired()

      it 'isExpired  should be true', ->
        expect(isExpired).to.be.ok

    context 'when token is a string',->
      beforeEach inject (store, jwtHelper) ->
        stateGetStub   = sinon.stub(store, 'get').returns token
        expiredTokenSpy = sinon.spy jwtHelper, 'isTokenExpired'
        isExpired = srv.tokenIsExpired()

      afterEach ->
        stateGetStub.restore()
        expiredTokenSpy.restore()

      it 'should have called jwtHelper.isTokenExpired', ->
        wasCalledWith = expiredTokenSpy.calledWith token
        expect(wasCalledWith).to.be.ok

