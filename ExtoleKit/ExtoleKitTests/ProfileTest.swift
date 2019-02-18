//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class ProfileTest: XCTestCase {

    let program = Program(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
    var programSession : ProgramSession!
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        program.getToken(success: { token in
            XCTAssert(token != nil)
            XCTAssert(!token!.access_token.isEmpty)
            self.programSession = ProgramSession.init(program: self.program, token: token!)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    
    func testIdentify() {
        let identify = expectation(description: "identify response")
        programSession.identify(email: "testidentify@extole.com") { error in
            identify.fulfill()
            XCTAssertNil(error)
        }
        wait(for: [identify], timeout: 10)
        
        let verifyIdentity = expectation(description: "verifyIdentity response")
        self.programSession.getProfile() { profile, error in
            XCTAssertNil(error)
            XCTAssertEqual("testidentify@extole.com", profile?.email)
            verifyIdentity.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testUpdateProfile() {
        let myProfile = MyProfile(email: "testprofile@extole.com",
                                  partner_user_id: "Zorro",
                                  first_name: "Test",
                                  last_name: "Profile")
        let identify = expectation(description: "identify response")
        programSession.updateProfile(profile: myProfile) { error in
            XCTAssertNil(error)
            identify.fulfill()
        }
        wait(for: [identify], timeout: 10)
        
        let verifyIdentity = expectation(description: "verifyIdentity response")
        programSession.getProfile() { profile, callback in
            XCTAssertEqual(profile?.email, myProfile.email)
            XCTAssertEqual(profile?.partner_user_id, myProfile.partner_user_id)
            XCTAssertEqual(profile?.first_name, myProfile.first_name)
            XCTAssertEqual(profile?.last_name, myProfile.last_name)
            verifyIdentity.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

}
