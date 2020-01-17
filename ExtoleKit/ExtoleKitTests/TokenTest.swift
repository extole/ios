//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class AuthenticationTest: XCTestCase {

    let program = Program(programURL: URL.init(string: "https://ios-santa.extole.io")!)
    
    func testCreateSession() {
        let promise = expectation(description: "create token response")
        program.createSession(success: { session in
            XCTAssert(session.token.access_token.count > 0)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testInvalidToken() {
        let promise = expectation(description: "invalid token response")
        program.resumeSession(accessToken: "invalid", success: { session in
            XCTFail("unexpected success")
        }, error: { verifyTokenError in
            print(verifyTokenError)
            XCTAssertEqual("invalid_access_token", verifyTokenError.code)
            promise.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDeleteToken() {
        let createSession = expectation(description: "get token response")

        var session: ProgramSession!
        program.createSession(success: { newSession in
            XCTAssert(!newSession.token.access_token.isEmpty)
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
