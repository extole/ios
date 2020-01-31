//Copyright © 2019 Extole. All rights reserved.

import XCTest
@testable import ExtoleAPI
@testable import ExtoleApp

class SimpleShareExperienceTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    func testShareExperince() {
        let submitShare = expectation(description: "share")
        let shareExperince = ExtoleApp.ExtoleShareExperince(programDomain: "ios-santa.extole.io", programLabel: "refer-a-friend")
        shareExperince.reset()
        let shareId = String(mach_absolute_time())
        shareExperince.async { shareApp in
            if let existingApp = shareApp {
                XCTAssertNotNil(existingApp.mobileSharing)
                let shareCode = existingApp.mobileSharing?.data.me["share_code"]
                XCTAssertNotNil(shareCode)
            } else {
                XCTFail("empty app")
            }
        }
        sleep(10)
        
        shareExperince.async { shareApp in
            if let existingApp = shareApp {
                let shareCode = existingApp.mobileSharing?.data.me["share_code"]
                XCTAssertNotNil(shareCode)
                let shareData: [String: String] = [
                   "share.message": "message",
                   "share.recipient": "friend@example.com",
                   "share.channel": "EMAIL",
                   "share.advocate_code": shareCode ?? "",
                   "sku": "ps5",
                   "partner_share_id": shareId
                ]
                
                existingApp.session?.submitEvent(eventName: "shared",
                      data: shareData,
                      success: { status in
                        XCTAssertNotNil(status.event_id)
                        submitShare.fulfill();
                       },
                      error: { e in
                    XCTFail(e.code)
                })
            }
        }
        
        wait(for: [submitShare], timeout: 5)
        
        let listShare = expectation(description: "list shares")
        
        shareExperince.async { shareApp in
            if let existingApp = shareApp {
              existingApp.session?.getShares(success: { shares in
                    XCTAssertEqual(1, shares.count)
                    XCTAssertEqual("friend@example.com", shares[0].recipient_email)
                    XCTAssertEqual(["sku": "ps5", "partner_share_id": shareId], shares[0].data)
                    listShare.fulfill()
                }, error: { e in
                    XCTFail(e.code)
                })
            }
        }
        
        wait(for: [listShare], timeout: 5)
    }
}

