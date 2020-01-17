//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class TokenTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programURL: URL.init(string: "https://ios-santa.extole.io")!)
    
    func testCreateToken() {
        let promise = expectation(description: "create token response")
        extoleAPI.createToken(success: { token in
            XCTAssert(!token.access_token.isEmpty)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testInvalidToken() {
        let invalidToken = ConsumerToken.init(access_token: "invalid")
        let programSession = ConsumerSession.init(program: extoleAPI, token: invalidToken)
        let promise = expectation(description: "invalid token response")
        programSession.verifyToken(success: { token in
            XCTFail("unexpected success")
        }, error: { verifyTokenError in
            print(verifyTokenError)
            XCTAssertEqual("invalid_access_token", verifyTokenError.code)
            promise.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDeleteToken() {
        let getToken = expectation(description: "get token response")

        var token: ConsumerToken!
        extoleAPI.createToken(success: { tokenResponse in
            XCTAssert(!tokenResponse.access_token.isEmpty)
            token = tokenResponse
            getToken.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
        
        let deleteToken = expectation(description: "delete token response")
        
        let programSession = ConsumerSession.init(program: self.extoleAPI, token: token)
        programSession.deleteToken(success: {
             deleteToken.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })

        waitForExpectations(timeout: 5, handler: nil)
        
        let verifyTokenDeleted = expectation(description: "verify delete response")
        
        programSession.verifyToken(success: { token in
            XCTFail("unexpected success")
        }, error: { error in
            XCTAssertTrue(error.isInvalidAccessToken())
            verifyTokenDeleted.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }

}
