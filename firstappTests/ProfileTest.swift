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

    let program = Program(baseUrl: "https://roman-tibin-test.extole.com")
    var accessToken: ConsumerToken?
    
    override func setUp() {
        let tokenResponse = program.getToken().await(timeout: DispatchTime.now() + .seconds(10))
        self.accessToken = tokenResponse
        XCTAssert(accessToken != nil)
        XCTAssert(!accessToken!.access_token.isEmpty)
    }

    func testProfile() {
        let tokenResponse = program.getToken()
        let accessToken = tokenResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssert(accessToken != nil)
        XCTAssert(!accessToken!.access_token.isEmpty)
        let myProfile = MyProfile(email: "testprofile@extole.com",
                                  first_name: "Test",
                                  last_name: "Profile",
                                  partner_user_id: "Zorro")
        
        let updateResponse = program.updateProfile(accessToken: accessToken!,
                                                   profile: myProfile)
            .await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertEqual("success", updateResponse?.status)
        
        let profileResponse = program.getProfile(accessToken: accessToken!)
            .await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertEqual(profileResponse?.email, myProfile.email)
    }

}
