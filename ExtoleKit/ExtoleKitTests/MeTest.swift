//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class MeTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")
    var extoleSession: ExtoleAPI.Session!
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        extoleAPI.createSession(success: { session in
            self.extoleSession = session
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    public func testShares() {
        extoleSession.getShares(success: { shares in
            XCTAssertEqual(0, shares.count)
        }, error: { error in
             XCTFail(String(reflecting: error))
        })
    }
}
