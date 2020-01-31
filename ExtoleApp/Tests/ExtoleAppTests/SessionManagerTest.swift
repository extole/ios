//Copyright © 2019 Extole. All rights reserved.

import XCTest
import ExtoleAPI

@testable import ExtoleApp

import Foundation

class SessionManagerTest: XCTestCase {

let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")

    var sessionManager: SessionManager!
    
    override func setUp() {
        super.setUp()
        sessionManager = extoleAPI.sessionManager()
    }
    
    public func testPrefetch() {
        let prefrech = expectation(description: "prefetch")
        
        sessionManager.prefetch { mobileSharing in
            XCTAssertNotNil(mobileSharing.data.me["share_code"])
            prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
    }
}

