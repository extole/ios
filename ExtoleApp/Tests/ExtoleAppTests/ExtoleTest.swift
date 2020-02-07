//Copyright © 2019 Extole. All rights reserved.

import Foundation
import XCTest
import ExtoleAPI

@testable import ExtoleApp

import Foundation

class ExtoleTest: XCTestCase {

    public func testLoadProgram() {
        let extole = Extole.init(programDomain: "ios-santa.extole.io")
        let program = extole.session().program(labels: "refer-a-friend")
        let prefrech = expectation(description: "prefetch")
        program.ready { mobileSharing in
            XCTAssertEqual("refer-a-friend", mobileSharing.program_label)
            XCTAssertNotNil(mobileSharing.links.company_url)
            XCTAssertNotNil(mobileSharing.me.advocate_code)
            prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
    }
}
