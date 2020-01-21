//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

import class ExtoleKit.Network;

class AuthenticationTest: XCTestCase {

    let extoleApi = ExtoleAPI(programDomain: "ios-santa.extole.io")
    
    func testCreateSession() {
        let promise = expectation(description: "create token response")
        extoleApi.createSession(success: { session in
            XCTAssert(session.accessToken.count > 0)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCreateSessionWithEmail() {
       let promise = expectation(description: "create token response")
       let tokenRequest = ExtoleAPI.Authorization.CreateTokenRequest.init(email: "test@gmail.com", jwt: nil, duration_seconds: nil)
           extoleApi.createSession(
            tokenRequest: tokenRequest,
            success: { session in
               XCTAssert(session.accessToken.count > 0)
               promise.fulfill()
           }, error: { error in
               XCTFail(String(reflecting: error))
           })
           waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCreateInvalidJwt() {
        let promise = expectation(description: "create token response")
        let tokenRequest = ExtoleAPI.Authorization.CreateTokenRequest.init(email: nil, jwt: "jwt", duration_seconds: nil)
        extoleApi.createSession(
         tokenRequest: tokenRequest,
         success: { session in
            promise.fulfill()
            XCTFail("JWT expected to fail, received valid token instead")
            
        }, error: { error in
            promise.fulfill()
            XCTAssertEqual("jwt_error", error.code)
            
        })
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testInvalidToken() {
        let promise = expectation(description: "invalid token response")
        extoleApi.createSession(accessToken: "invalid", success: { session in
            XCTFail("unexpected success")
        }, error: { verifyTokenError in
            XCTAssertEqual("invalid_access_token", verifyTokenError.code)
            XCTAssertEqual(403, verifyTokenError.httpCode ?? -1)
            XCTAssertEqual("The access_token provided with this request is invalid.", verifyTokenError.message)
            promise.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDeleteToken() {
        let createSession = expectation(description: "get token response")

        var session: ExtoleAPI.Session!
        extoleApi.createSession(success: { newSession in
            XCTAssert(!newSession.accessToken.isEmpty)
            session = newSession
            createSession.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
        
        let deleteToken = expectation(description: "delete token response")
        
        session.invalidate(success: {
             deleteToken.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })

        waitForExpectations(timeout: 5, handler: nil)
        
        let verifyTokenDeleted = expectation(description: "verify delete response")
        
        session.verify(success: { token in
            XCTFail("unexpected success")
        }, error: { error in
            XCTAssertTrue(error.isInvalidAccessToken())
            verifyTokenDeleted.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }

}
