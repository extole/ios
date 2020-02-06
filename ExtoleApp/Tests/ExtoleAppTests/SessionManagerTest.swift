//Copyright © 2019 Extole. All rights reserved.

import XCTest
import ExtoleAPI

@testable import ExtoleApp

import Foundation

class SessionManagerTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")
    
    public func testPrefetch() {
        let sessionManager = extoleAPI.sessionManager()
        let prefrech = expectation(description: "prefetch")
        sessionManager.loadMobileSharing { mobileSharing in
            XCTAssertNotNil(mobileSharing.me.share_code)
            prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
    }
    
    public func testIdentifyAndPrefetch() {
        let prefrech = expectation(description: "prefetch")
        let advocateEmail = "john@ios-stanta.extole.com"
        
        let sessionManager = extoleAPI.sessionManager(email: advocateEmail)
        
        sessionManager.loadMobileSharing { (mobileSharing: ExtoleApp.MobileSharing) in
                XCTAssertEqual(advocateEmail, mobileSharing.me.email)
            prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
    }
    
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

