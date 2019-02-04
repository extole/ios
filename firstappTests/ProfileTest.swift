//
//  ProfileTest.swift
//  firstappTests
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import XCTest

@testable import firstapp

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

    func testProfile() {
        let myProfile = MyProfile(email: "testprofile@extole.com",
                                  partner_user_id: "Zorro",
                                  first_name: "Test",
                                  last_name: "Profile")
        
        let updateResponse = program.updateProfile(accessToken: accessToken!,
                                                   profile: myProfile)
            .await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertEqual("success", updateResponse?.status)
        
        let profileResponse = program.getProfile(accessToken: accessToken!)
            .await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertEqual(profileResponse?.email, myProfile.email)
    }

}
