//
//  ProfileTest.swift
//  firstappTests
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import XCTest

@testable import ExtoleKit

class ProfileTest: XCTestCase {

    let program = Program(baseUrl: URL.init(string: "https://roman-tibin-test.extole.com")!)
    var accessToken: ConsumerToken?
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        program.getToken() { token, error in
            XCTAssert(token != nil)
            XCTAssert(!token!.access_token.isEmpty)
            self.accessToken = token
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    
    func testIdentify() {
        let identify = expectation(description: "identify response")
        program.identify(accessToken: accessToken!,
                        email: "testidentify@extole.com") { error in
            identify.fulfill()
            XCTAssertNil(error)
        }
        wait(for: [identify], timeout: 10)
        
        let verifyIdentity = expectation(description: "verifyIdentity response")
        self.program.getProfile(accessToken: self.accessToken!) { profile, error in
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
        program.updateProfile(accessToken: accessToken!, profile: myProfile) { error in
            XCTAssertNil(error)
            identify.fulfill()
        }
        wait(for: [identify], timeout: 10)
        
        let verifyIdentity = expectation(description: "verifyIdentity response")
        program.getProfile(accessToken: accessToken!) { profile, callback in
            XCTAssertEqual(profile?.email, myProfile.email)
            XCTAssertEqual(profile?.partner_user_id, myProfile.partner_user_id)
            XCTAssertEqual(profile?.first_name, myProfile.first_name)
            XCTAssertEqual(profile?.last_name, myProfile.last_name)
            verifyIdentity.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

}
