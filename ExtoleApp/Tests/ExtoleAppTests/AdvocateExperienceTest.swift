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
        let advocateEmail = String(format: "adv-%lu@extole.com", mach_absolute_time())
        let sessionManager = extoleAPI.sessionManager(email: advocateEmail)
        let loaded = expectation(description: "advocate experience loaded")

        sessionManager
            .loadAdvocateExperience(success: { advocateExperience in
                XCTAssertEqual(advocateEmail, advocateExperience.me.email)
                XCTAssertEqual("Give $20, Get $20", advocateExperience.mobileSharing.page.reward)
                loaded.fulfill()
        })
        wait(for: [loaded], timeout: 5)
    }
}

