//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class ZoneTest: XCTestCase {

    let program = ExtoleAPI(programDomain: "ios-santa.extole.io")
    var programSession: ExtoleSession!
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        program.createToken(success: { token in
            XCTAssert(!token.access_token.isEmpty)
            self.programSession = ExtoleSession.init(program: self.program, token: token)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    struct Settings : Codable {
        let shareMessage: String
    }
    
    func testFetchSettings() {
        let promise = expectation(description: "fetch object")
        programSession.fetchObject(zone: "settings",
                                   success: { (settings: Settings?) in
            XCTAssertEqual("Share message", settings?.shareMessage)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
    }

}
