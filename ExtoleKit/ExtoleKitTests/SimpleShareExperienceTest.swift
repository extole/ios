//Copyright © 2019 Extole. All rights reserved.

import XCTest
@testable import ExtoleKit

class SimpleShareExperienceTest: XCTestCase {

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

    struct MobileSharing: Codable {
        struct Data: Codable{
            let me: [String: String]
        }
        let event_id: String
        let data: Data
    }
    
    func testShare() {
        let promise = expectation(description: "fetch mobile_menu")
        var shareCode: String!
        extoleSession.renderZone(eventName: "mobile_sharing",
                                  success: { (menu: MobileSharing) in
            shareCode = menu.data.me["share_code"]
            XCTAssertNotNil(shareCode)
            promise.fulfill()
        }, error: { error in
           XCTFail(error.code)
        })
        wait(for: [promise], timeout: 5)
        let shareId = String(mach_absolute_time())
        let shareData: [String: String] = [
           "share.message": "message",
           "share.recipient": "friend@example.com",
           "share.channel": "EMAIL",
           "share.advocate_code": shareCode,
           "sku": "ps5",
           "partner_share_id": shareId
        ]
        let submitShare = expectation(description: "submit share")
        
        extoleSession.submitEvent(eventName: "shared",
              data: shareData,
              success: { status in
                XCTAssertNotNil(status.event_id)
                submitShare.fulfill();
               },
              error: { e in
            XCTFail(e.code)
        })
        sleep(5)
        wait(for: [submitShare], timeout: 5)
        
        let listShare = expectation(description: "list shares")
        extoleSession.getShares(success: { shares in
            XCTAssertEqual(1, shares.count)
            XCTAssertEqual("friend@example.com", shares[0].recipient_email)
            XCTAssertEqual(["sku": "ps5", "partner_share_id": shareId], shares[0].data)
            listShare.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [listShare], timeout: 5)
    }

    func testFetchSettings() {
        let promise = expectation(description: "settings response")
        let shareApp = ExtoleShareExperince(programDomain: "ios-santa.extole.io", programLabel: "missing")
        shareApp.reset()
        
        shareApp.fetchObject(zone: "settings", success: { (settings: Settings) in
             promise.fulfill()
        }, error: { (error) in
             XCTFail("unexpected error " + error.code)
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSignal() {
        let promise = expectation(description: "conversion response")
        let shareApp = ExtoleShareExperince(programDomain: "ios-santa.extole.io", programLabel: "missing")
        shareApp.reset()
        let parameters : [String: String] = [
            "cart_value": "12.31"
        ]
        shareApp.signal(zone: "conversion", data: parameters, success: { response in
            XCTAssertNotNil(response.event_id)
            promise.fulfill()
        }, error: { (error) in
            XCTFail("unexpected error " + error.code)
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testUpdateProfile() {
        let updateProfile = expectation(description: "update profile")
        let shareApp = ExtoleShareExperince(programDomain: "ios-santa.extole.io", programLabel: "missing")
        shareApp.reset()
        
        shareApp.update(first_name: "test profile", success: {
            updateProfile.fulfill()
        }, error: { (error) in
            XCTFail("unexpected error " + error.code)
        })
        
        wait(for: [updateProfile], timeout: 5)
        let fetchProfile = expectation(description: "fetch profile")
        
        shareApp.async { (app) in
            app?.session?.getProfile(success: { (profile) in
                XCTAssertEqual("test profile", profile.first_name)
                fetchProfile.fulfill()
            }, error: { error in
                 XCTFail("unexpected error " + error.code)
            })
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}

