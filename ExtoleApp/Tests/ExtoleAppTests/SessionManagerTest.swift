//Copyright © 2019 Extole. All rights reserved.

import XCTest
import ExtoleAPI

@testable import ExtoleApp

import Foundation

class SessionManagerTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")
    
    public func testAsync() {
        let sessionManager = extoleAPI.sessionManager()
        let asynced = expectation(description: "test async")
        sessionManager.async { session in
            session.getProfile(success: { myProfile in
                asynced.fulfill()
            }, error: { e in
                XCTFail(e.message ?? e.code)
            })
        }
        wait(for: [asynced], timeout: 5)
    }
}

