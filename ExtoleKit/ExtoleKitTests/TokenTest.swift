//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class TokenTest: XCTestCase {

    let program = ProgramURL(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
    
    func testGetToken() {
        let promise = expectation(description: "get token response")
        program.getToken(success: { token in
            XCTAssert(token != nil)
            XCTAssert(!token!.access_token.isEmpty)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testInvalidToken() {
        let invalidToken = ConsumerToken.init(access_token: "invalid")
        let programSession = ConsumerSession.init(program: program, token: invalidToken)
        let promise = expectation(description: "invalid token response")
        programSession.getToken(success: { token in
            XCTFail("unexpected success")
        }, error: { verifyTokenError in
            switch(verifyTokenError) {
            case .invalidAccessToken : do {
                promise.fulfill()
                }
            default : XCTFail("Unexpected error: \(verifyTokenError)")
            }
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDeleteToken() {
        let getToken = expectation(description: "get token response")

        var token: ConsumerToken!
        program.getToken(success: { tokenResponse in
            XCTAssert(tokenResponse != nil)
            XCTAssert(!tokenResponse!.access_token.isEmpty)
            token = tokenResponse
            getToken.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
        
        let deleteToken = expectation(description: "delete token response")
        
        let programSession = ConsumerSession.init(program: self.program, token: token)
        programSession.deleteToken(success: {
             deleteToken.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })

        waitForExpectations(timeout: 5, handler: nil)
        
        let verifyTokenDeleted = expectation(description: "verify delete response")
        
        programSession.getToken(success: { token in
            XCTFail("unexpected success")
        }, error: { error in
            switch(error) {
            case GetTokenError.invalidAccessToken: break
            default: XCTFail("Unexpected error \(error)")
            }
            verifyTokenDeleted.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }

}
