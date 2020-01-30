//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class EventsTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")
    var extoleSession: ExtoleAPI.Session!
    
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
    
    public func testSubmitShare() {
        let sharedExpectation = expectation(description: "shared")
        let shareData: [String: String] = [
            "share.message": "message",
            "share.recipient": "friend@example.com",
            "share.channel": "EMAIL"
        ]
        
        extoleSession.submitEvent(eventName: "share", data: shareData,
                                  success: { shared in
            XCTAssertNotNil(shared.event_id)
            sharedExpectation.fulfill()
        }, error: { error in
            XCTFail(error.code)
        })
        
        sleep(5)
        wait(for: [sharedExpectation], timeout: 1)
        
        
        let getShares = expectation(description: "get shares")
        extoleSession.getShares(success: { shares in
            XCTAssertEqual(1, shares.count)
            getShares.fulfill()
        }, error: { error in
            XCTFail(error.code)
        })
        
        wait(for: [getShares], timeout: 5)
    }
}
