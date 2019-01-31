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

    let program = Program(baseUrl: URL.init(string: "https://roman-tibin-test.extole.com")!)

    func testGetToken() {
        let promise = expectation(description: "invalid token response")
        program.getToken() { token, error in
            XCTAssert(token != nil)
            XCTAssert(!token!.access_token.isEmpty)
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testInvalidToken() {
        let promise = expectation(description: "invalid token response")
        program.getToken(token: "invalid") { token, error in
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
