//Copyright © 2019 Extole. All rights reserved.

import XCTest
@testable import ExtoleAPI
@testable import ExtoleApp

class ShareExperienceTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    func testShareExperince() {
        let shareExperince = ExtoleApp.ShareExperince(programDomain: "ios-santa.extole.io", programLabel: "refer-a-friend")
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
        
        let shareData: [String: String] = [
          "share.message": "message",
          "share.recipient": "friend@example.com",
          "share.channel": "EMAIL",
          "sku": "ps5",
          "partner_share_id": shareId
        ]
        
        let submitShare = expectation(description: "submit shares")
        
        shareExperince.share(data: shareData, success: { submit in
            XCTAssertNotNil(submit.event_id)
            submitShare.fulfill();
        }, error: { e in
            XCTFail(e.code)
            submitShare.fulfill();
        })
        
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

