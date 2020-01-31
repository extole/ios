//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleAPI

class ShareTest: XCTestCase {

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
    
    func testEmailShare() {
        let sharePromise = expectation(description: "share")
        let friend = "ios-friend.k1uu7gsb@mailosaur.io"
        extoleSession!.emailShare(
            recipient: friend,
            message: "test message",
            subject: "ios-test",
            data: [ "source": "ShareTest"],
            success: { emailResponse in
            XCTAssertNotNil(emailResponse.polling_id)
            sharePromise.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        
        sleep(5)
        wait(for: [sharePromise], timeout: 5)
        
        let shareVerify = expectation(description: "share")
        extoleSession.getShares(success: { shares in
            XCTAssertEqual(1, shares.count)
            shareVerify.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [shareVerify], timeout: 5)
    }
}
