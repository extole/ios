//Copyright © 2019 Extole. All rights reserved.

import Foundation
import XCTest
import ExtoleAPI

@testable import ExtoleApp

import Foundation

class ExtoleTest: XCTestCase {

    public func testLoadProgram() {
        let extole = Extole.init(programDomain: "ios-santa.extole.io")
        let program = extole.session().program()
        let prefrech = expectation(description: "prefetch")
        program.ready { mobileSharing in
            XCTAssertEqual("refer-a-friend-mobile-app", mobileSharing.label)
            XCTAssertEqual("mobile_sharing", mobileSharing.bundle_name)
            XCTAssertNotNil(mobileSharing.target_url)
            XCTAssertNotNil(mobileSharing.me.share_code)
            prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
    }
}
