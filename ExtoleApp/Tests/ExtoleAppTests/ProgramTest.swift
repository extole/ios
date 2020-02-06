//Copyright © 2019 Extole. All rights reserved.

import XCTest
import ExtoleAPI

@testable import ExtoleApp

import Foundation

class ProgramTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")
    
    public func testLoadProgram() {
        let program = extoleAPI.sessionManager().getProgram()
        let prefrech = expectation(description: "prefetch")
        program.load { mobileSharing in
            XCTAssertEqual("refer-a-friend-mobile-app", mobileSharing.label)
            XCTAssertEqual("mobile_sharing", mobileSharing.bundle_name)
            XCTAssertNotNil(mobileSharing.target_url)
            XCTAssertNotNil(mobileSharing.me.share_code)
            prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
    }
    
    public func testIdentifyAndLoad() {
        let prefrech = expectation(description: "prefetch")
        let advocateEmail = String(format: "adv-%lu@extole.com", mach_absolute_time())
        
        let program = extoleAPI.sessionManager(email: advocateEmail).getProgram()
        
        program.load { (mobileSharing: ExtoleApp.MobileSharing) in
                XCTAssertEqual(advocateEmail, mobileSharing.me.email)
            prefrech.fulfill()
        }
        wait(for: [prefrech], timeout: 5)
    }
    
    func testShare() {
        
        let advocateEmail = String(format: "adv-%lu@extole.com", mach_absolute_time())
        let friendEmail = String(format: "fr-%lu@extole.com", mach_absolute_time())
        let program = extoleAPI.sessionManager(email: advocateEmail).getProgram()
        let shareId = String(mach_absolute_time())
        
        let loaded = expectation(description: "program loaded")
        program.load { mobileSharing in
            XCTAssertNotNil(mobileSharing.me.share_code)
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 5)
        
        let shareData: [String: String] = [
          "share.message": "message",
          "share.recipient": friendEmail,
          "share.channel": "EMAIL",
          "sku": "ps5",
          "partner_share_id": shareId
        ]
        
        let submitShare = expectation(description: "submit shares")
        program.share(data: shareData, success: { submit in
            XCTAssertNotNil(submit.event_id)
            submitShare.fulfill();
        }, error: { e in
            XCTFail(e.code)
            submitShare.fulfill();
        })
        wait(for: [submitShare], timeout: 5)
        
        let listShare = expectation(description: "list shares")
        program.sessionManager.async { session in
            session.getShares(success: { shares in
                XCTAssertEqual(1, shares.count)
                XCTAssertEqual("friend@example.com", shares[0].recipient_email)
                XCTAssertEqual(["sku": "ps5", "partner_share_id": shareId], shares[0].data)
                listShare.fulfill()
            }, error: { e in
                XCTFail(e.code)
            })
        }
        wait(for: [listShare], timeout: 5)
    }
}
