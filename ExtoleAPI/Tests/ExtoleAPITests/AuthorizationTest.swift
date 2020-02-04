//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleAPI

import class ExtoleAPI.Network;

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
       
       extoleApi.createSession(
        email: "test@gmail.com",
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
        extoleApi.createSession(jwt: "jwt",
                                success: { session in
            XCTFail("JWT expected to fail, received valid token instead")
            }, error: { e in
                XCTAssertEqual(ExtoleAPI.Authorization.CreateSessionError.Code.jwt_error, e.code)
            XCTAssertEqual(
                ["reason":
                    "MALFORMED",
                 "description":
                    "The token could not be verified, make sure it is in compliance with rfc7519 specification."
            ], e.error.parameters)
            promise.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testInvalidToken() {
        let promise = expectation(description: "invalid token response")
        extoleApi.resumeSession(accessToken: "invalid", success: { session in
            XCTFail("unexpected success")
        }, error: { e in
            XCTAssertEqual(ExtoleAPI.Authorization.ResumeSessionError.Code.invalid_access_token,
                e.code)
            XCTAssertEqual(403, e.error.httpCode ?? -1)
            XCTAssertEqual("The access_token provided with this request is invalid.", e.error.message)
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
