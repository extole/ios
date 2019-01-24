//
//  firstappTests.swift
//  firstappTests
//
//  Created by rtibin on 1/11/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import XCTest

@testable import firstapp

class ExtoleAPITest: XCTestCase {

    let program = Program(baseUrl: "https://roman-tibin-test.extole.com")
 
    override func setUp() {
        Logger.Info(message: "setup")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
         Logger.Info(message: "teardown")
    }

    func testGetToken() {
        let tokenResponse = program.getToken()
        let accessToken = tokenResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssert(accessToken != nil)
        XCTAssert(!accessToken!.access_token.isEmpty)
    }
    
    func testCreateShareable() {
        let tokenResponse = program.getToken()
        let accessToken = tokenResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssert(accessToken != nil)
        XCTAssert(!accessToken!.access_token.isEmpty)
        let newShareable = MyShareable(label: "refer-a-friend")
        let shareableResponse = program.createShareable(accessToken: accessToken!,
                                                          shareable: newShareable)
        let shareableResult = shareableResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertGreaterThan(shareableResult!.polling_id, "111111")
        
        let pollingResult = program.pollShareable(accessToken: accessToken!,
                              pollingResponse: shareableResult!)
            .await(timeout: DispatchTime.now() + .seconds(10))
        
        XCTAssertGreaterThan(pollingResult!.code, "1111")
        
        let shareablesResponse = program.getShareables(accessToken: accessToken!)
            .await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertNotNil(shareablesResponse)
        XCTAssertEqual(1, shareablesResponse?.count)
        XCTAssertEqual("refer-a-friend", shareablesResponse?.first?.label)
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
    
    func testCustomShare() {
        let tokenResponse = program.getToken()
        let accessToken = tokenResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssert(accessToken != nil)
        XCTAssert(!accessToken!.access_token.isEmpty)
        let newShareable = MyShareable(label: "refer-a-friend")
        let shareableResponse = program.createShareable(accessToken: accessToken!,
                                                        shareable: newShareable)
        let shareableResult = shareableResponse.await(timeout: DispatchTime.now() + .seconds(10))
        
        let shareable = program.pollShareable(accessToken: accessToken!, pollingResponse: shareableResult!)
            .await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertEqual("SUCCEEDED", shareable?.status)
        XCTAssertGreaterThan(shareable!.code, "1111")
    
        let customShare = CustomShare(advocate_code: shareable!.code,
                                                channel: "EMAIL",
                                                message: "testmessage",
                                                recipient_email: "rtibin@extole.com",
                                                data: [:])
        
        let shareResponse = program.customShare(accessToken : accessToken!, share: customShare)
            .await(timeout: DispatchTime.now() + .seconds(10))
        
        XCTAssertGreaterThan(shareResponse!.polling_id, "1111")
        let customShareResult = program.pollCustomShare(accessToken: accessToken!,
                pollingResponse: shareResponse!)
            .await(timeout: DispatchTime.now() + .seconds(10))
        
        XCTAssertGreaterThan(customShareResult!.share_id, "1111")
    }
    
    func testFetchZone() {
        let shareLinkResponse = program.fetchZone(accessToken: nil,
                                                    zone: "share_experience")
        let shareLink = shareLinkResponse.await(timeout: DispatchTime.now() + .seconds(100))
        XCTAssert(shareLink != nil)
        let linkData = String.init(data: shareLink!, encoding: String.Encoding.utf8)!
        Logger.Debug(message: "share_link : \(linkData)")
        XCTAssert(linkData.contains("extole.define"))
    }

}
