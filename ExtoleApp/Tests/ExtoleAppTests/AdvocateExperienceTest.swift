//Copyright © 2019 Extole. All rights reserved.

import Foundation

import XCTest
@testable import ExtoleAPI
@testable import ExtoleApp

class AdvocateExperienceTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")

    var sessionManager: ExtoleApp.SessionManager!
    
    override func setUp() {
        super.setUp()
        sessionManager = extoleAPI.sessionManager()
    }

    func testLoadAdvocateExperience() {
        let loaded = expectation(description: "advocate experience loaded")
        let advocateEmail = String(format: "adv-%lu@extole.com", mach_absolute_time())
        sessionManager
            .identify(email: advocateEmail)
            .loadAdvocateExperience(success: { advocateExperience in
                XCTAssertEqual(advocateEmail, advocateExperience.me.email)
                XCTAssertEqual("Give $20, Get $20", advocateExperience.mobileSharing.page.reward)
                loaded.fulfill()
        })
        wait(for: [loaded], timeout: 5)
    }
}

