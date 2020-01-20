//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class ZoneTest: XCTestCase {

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
    
    struct Settings : Codable {
        let shareMessage: String
    }
    
    func testRenderZone() {
        struct TestResponse: Codable {
            let event_id: String
        }
        let promise = expectation(description: "render zone")
        extoleSession.renderZone(eventName: "settings",
                                 data:[:],
                                 success: { (response: TestResponse) in
           XCTAssertNotNil(response.event_id)
           promise.fulfill()
        }, error: { error in
           XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
   }
    
    func testFetchSettings() {
        let promise = expectation(description: "fetch object")
        extoleSession.fetchObject(zone: "settings",
                                   success: { (settings: Settings?) in
            XCTAssertEqual("Share message", settings?.shareMessage)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
    }

}
