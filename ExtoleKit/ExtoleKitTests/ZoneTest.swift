//
//  firstappTests.swift
//  firstappTests
//
//  Created by rtibin on 1/11/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import XCTest

@testable import ExtoleKit

class ZoneTest: XCTestCase {

    let program = Program(baseUrl: URL.init(string: "https://roman-tibin-test.extole.com")!)
    var accessToken: ConsumerToken?
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        program.getToken() { token, error in
            XCTAssert(token != nil)
            XCTAssert(!token!.access_token.isEmpty)
            self.accessToken = token
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    struct Settings : Codable {
        let shareMessage: String
    }
    
    func testFetchSettings() {
        let promise = expectation(description: "fetch object")
        program.fetchObject(accessToken: accessToken!,
                            zone: "settings") { (settings: Settings?, error) in
            XCTAssertEqual("Share message", settings?.shareMessage)
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

}
