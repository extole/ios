//Copyright © 2019 Extole. All rights reserved.

import Foundation

import XCTest

@testable import ExtoleAPI

class ShareableTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")
    var extoleSession: ExtoleAPI.Session!
    var advocateCode: String?
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        extoleAPI.createSession(success: { session in
            self.extoleSession = session
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCreateShareable() {
        let shareablesVerify = expectation(description: "shreables")
        extoleSession.getShareables(success: { shareables in
            XCTAssertEqual(0, shareables.count)
            shareablesVerify.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        
        let preferredCode = String(format: "code-%lu", mach_absolute_time())
        wait(for: [shareablesVerify], timeout: 5)
        
        let createShareable = expectation(description: "shreables")
        extoleSession.createShareable(preferred_code_prefixes: [preferredCode],
                                      success: { newShareable in
            XCTAssertEqual(preferredCode, newShareable.code)
            createShareable.fulfill()
                                        
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [createShareable], timeout: 5)
        
        let lookupByCode = expectation(description: "lookup shareable by code")
        extoleSession.getShareable(code: preferredCode, success: { byCode in
            XCTAssertNotNil(byCode.link)
            lookupByCode.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [lookupByCode], timeout: 5)
        
        let shareablesList = expectation(description: "shreables")
        extoleSession.getShareables(success: { shareables in
           XCTAssertEqual(1, shareables.count)
           shareablesList.fulfill()
        }, error: { e in
           XCTFail(e.code)
        })
        wait(for: [shareablesList], timeout: 5)
    }
}
