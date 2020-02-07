//Copyright © 2019 Extole. All rights reserved.

import Foundation
import XCTest
import ExtoleAPI

@testable import ExtoleApp

import Foundation

extension ExtoleApp.MobileSharing {
    var custom_title: String {
        get {
            return data["sharing.facebook.title"] ?? "Share good things will happen"
        }
    }
}

extension ExtoleApp.MobileSharing.Twitter {
    var url : String? {
        get {
            return json["url"]
        }
    }
}

class MobileSharingTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")

    var sessionManager: ExtoleApp.SessionManager!
    
    override func setUp() {
        super.setUp()
        sessionManager = extoleAPI.sessionManager()
    }
   
    public func testExtendMobileSharing() {
        let loaded = expectation(description: "load extended sharing")
        sessionManager.loadMobileSharing { mobileSharing in
            XCTAssertEqual("Get $20 Off", mobileSharing.custom_title)
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 5)
    }
    
    public func testExtendMobileSharingData() {
        let loaded = expectation(description: "load extended sharing")
        sessionManager.loadMobileSharing { mobileSharing in
            XCTAssertEqual("tweet", mobileSharing.sharing.twitter.url ?? "tweet")
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 5)
    }
}
