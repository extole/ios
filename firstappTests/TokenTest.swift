//
//  TokenTest.swift
//  firstappTests
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import XCTest

@testable import firstapp

class TokenTest: XCTestCase {

    let program = Program(baseUrl: "https://roman-tibin-test.extole.com")

    func testGetToken() {
        let tokenResponse = program.getToken()
        let accessToken = tokenResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssert(accessToken != nil)
        XCTAssert(!accessToken!.access_token.isEmpty)
    }
    
    func testInvalidToken() {
        let promise = expectation(description: "invalid token response")
        program.verifyToken(token: "invalid") { token, error in
            if let verifyTokenError = error {
                switch(verifyTokenError) {
                    case .invalidAccessToken : do {
                        promise.fulfill()
                    }
                    default : XCTFail("Unexpected error: \(verifyTokenError)")
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

}
