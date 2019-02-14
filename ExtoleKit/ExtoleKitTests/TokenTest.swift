//
//  TokenTest.swift
//  firstappTests
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import XCTest

@testable import ExtoleKit

class TokenTest: XCTestCase {

    let program = Program(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
    
    func testGetToken() {
        let promise = expectation(description: "get token response")
        program.getToken(success: { token in
            XCTAssert(token != nil)
            XCTAssert(!token!.access_token.isEmpty)
            promise.fulfill()
        }, error: { error in
            XCTFail(error.debugDescription)
        })
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testInvalidToken() {
        let invalidToken = ConsumerToken.init(access_token: "invalid")
        let programSession = ProgramSession.init(program: program, token: invalidToken)
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
            XCTFail(error.debugDescription)
        })
        waitForExpectations(timeout: 5, handler: nil)
        
        let deleteToken = expectation(description: "delete token response")
        
        let programSession = ProgramSession.init(program: self.program, token: token)
        programSession.deleteToken() { error in
            deleteToken.fulfill()
            XCTAssertNil(error)
            
        }

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
