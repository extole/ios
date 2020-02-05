//Copyright © 2019 Extole. All rights reserved.

import Foundation
import XCTest
import ExtoleAPI

@testable import ExtoleApp

import Foundation

extension ExtoleApp.MobileSharing {
    var how_it_works: String {
        get {
            return data["page.how_it_works"] ?? "Share good things will happen"
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
            XCTAssertEqual("Share Your Company with friends. You get $20 when they purchase!", mobileSharing.how_it_works)
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 5)
    }
    
    public func testExtendMobileSharingData() {
        let loaded = expectation(description: "load extended sharing")
        sessionManager.loadMobileSharing { mobileSharing in
            XCTAssertEqual("tweet", mobileSharing.twitter.url ?? "tweet")
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 5)
    }
}
