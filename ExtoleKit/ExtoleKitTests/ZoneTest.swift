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
    
    struct MobileMenu: Codable {
        let event_id: String
        let data: [String: String]
    }

    func testFetchMobileMenu() {
        let promise = expectation(description: "fetch mobile_menu")
        let mobileSharingUrl = "https://ios-santa.extole.io/" +
            "zone/mobile_sharing?via_zone=mobile_menu"
        extoleSession.renderZone(eventName: "mobile_menu",
                                   success: { (menu: MobileMenu) in
        XCTAssertEqual(mobileSharingUrl, menu.data["mobile_sharing_url"])
            promise.fulfill()
        }, error: { error in
            XCTFail(error.code)
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    struct MobileSharing: Codable {
        struct Data: Codable{
            let me: [String: String]
        }
        let event_id: String
        let data: Data
    }
    
    func testFetchMobileSharing() {
       let promise = expectation(description: "fetch mobile_menu")
       extoleSession.renderZone(eventName: "mobile_sharing",
                                  success: { (menu: MobileSharing) in
            XCTAssertNotNil(menu.data.me["share_code"])
            promise.fulfill()
       }, error: { error in
           XCTFail(error.code)
       })
       waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testMobileSharingFlat() {
       let promise = expectation(description: "fetch mobile_menu")
        let programUrl = "https://ios-santa.extole.io/"
       extoleSession.renderZone(eventName: "mobile_sharing",
                                success: { (zoneResponse: ExtoleAPI.Zones.ZoneResponse) in
            XCTAssertNotNil(zoneResponse.event_id)
            let shareCode = zoneResponse.data["me.share_code"];
            XCTAssertNotNil(shareCode)
            XCTAssertEqual(programUrl + shareCode!, zoneResponse.data["me.link"] ?? "")
            promise.fulfill()
       }, error: { error in
           XCTFail(error.code)
       })
       waitForExpectations(timeout: 5, handler: nil)
    }

}
