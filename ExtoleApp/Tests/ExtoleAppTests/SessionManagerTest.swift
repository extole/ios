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
        sessionManager.fetchMobileSharing { mobileSharing in
            XCTAssertNotNil(mobileSharing.data.me["share_code"])
            prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
    }
    
    public func testIdentifyAndPrefetch() {
        let prefrech = expectation(description: "prefetch")
        
        let advocateEmail = "john@ios-stanta.extole.com"
        sessionManager.identify(email: advocateEmail)
            .fetchMobileSharing { mobileSharing in
            XCTAssertEqual(advocateEmail, mobileSharing.data.me["email"])
            prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
    }
    
    public func testIdentifyInvalidatesSession() {
        let prefrech = expectation(description: "prefetch")

        sessionManager.fetchMobileSharing { mobileSharing in
            XCTAssertEqual("", mobileSharing.data.me["email"])
            prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
        
        let advocateEmail = "john@ios-stanta.extole.com"
        let identifiedPrefetch = expectation(description: "prefetch identified")
        sessionManager.identify(email: advocateEmail).fetchMobileSharing { mobileSharing in
            XCTAssertEqual(advocateEmail, mobileSharing.data.me["email"])
            identifiedPrefetch.fulfill()
        }
        wait(for: [identifiedPrefetch], timeout: 5)
    }
    
    public func testAnonymousInvalidatesSession() {
        let advocateEmail = "john@ios-stanta.extole.com"
        let identifiedPrefetch = expectation(description: "prefetch identified")
        sessionManager.identify(email: advocateEmail).fetchMobileSharing { mobileSharing in
            XCTAssertEqual(advocateEmail, mobileSharing.data.me["email"])
            identifiedPrefetch.fulfill()
        }
        wait(for: [identifiedPrefetch], timeout: 5)
        
        let prefrech = expectation(description: "prefetch")

        sessionManager.logout()
        sessionManager.fetchMobileSharing { mobileSharing in
           XCTAssertEqual("", mobileSharing.data.me["email"])
           prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
   }
}

