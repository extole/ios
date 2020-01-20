//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class ProfileTest: XCTestCase {

    let extoleApi = ExtoleAPI(programDomain: "ios-santa.extole.io")
    var extoleSession : ExtoleSession!
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        extoleApi.createSession(success: { session in
            self.extoleSession = session
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    
    func testIdentify() {
        let identify = expectation(description: "identify response")
        let identifyRequest = MyProfile(email: "testidentify@extole.com")
        extoleSession.updateProfile(profile: identifyRequest, success: {
            identify.fulfill()
        }, error : { error in
            XCTFail(String(reflecting: error))
        })
        
        wait(for: [identify], timeout: 10)
        
        let verifyIdentity = expectation(description: "verifyIdentity response")
        self.extoleSession.getProfile(success: { profile in
            XCTAssertEqual("testidentify@extole.com", profile.email)
            verifyIdentity.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
    
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testUpdateProfile() {
        let myProfile = MyProfile(email: "testprofile@extole.com",
                                  partner_user_id: "Zorro",
                                  first_name: "Test",
                                  last_name: "Profile")
        let identify = expectation(description: "identify response")
        extoleSession.updateProfile(profile: myProfile, success: {
                identify.fulfill()
            }, error : { error in
                XCTFail(String(reflecting: error))
        })
    
        wait(for: [identify], timeout: 10)
        
        let verifyIdentity = expectation(description: "verifyIdentity response")
        extoleSession.getProfile(success: { profile in
            XCTAssertEqual(profile.email, myProfile.email)
            XCTAssertEqual(profile.partner_user_id, myProfile.partner_user_id)
            XCTAssertEqual(profile.first_name, myProfile.first_name)
            XCTAssertEqual(profile.last_name, myProfile.last_name)
            verifyIdentity.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }

}
