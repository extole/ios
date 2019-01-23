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

    let extoleApi = ExtoleAPI.init(baseUrl: "https://roman-tibin-test.extole.com")
 
    override func setUp() {
        Logger.Info(message: "setup")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
         Logger.Info(message: "teardown")
    }

    func testGetToken() {
        let tokenResponse = extoleApi.getToken()
        let accessToken = tokenResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssert(accessToken != nil)
        XCTAssert(!accessToken!.access_token.isEmpty)
    }
    
    func testCreateShareable() {
        let tokenResponse = extoleApi.getToken()
        let accessToken = tokenResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssert(accessToken != nil)
        XCTAssert(!accessToken!.access_token.isEmpty)
        let newShareable = ExtoleAPI.MyShareable(label: "refer-a-friend")
        let pollingResponse = extoleApi.createShareable(accessToken: accessToken!,
                                                          shareable: newShareable)
        let polingResult = pollingResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertEqual("SUCCEEDED", polingResult?.status)
        XCTAssertGreaterThan(polingResult!.code, "1111")
        
        let shareablesResponse = extoleApi.getShareables(accessToken: accessToken!)
            .await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertNotNil(shareablesResponse)
        XCTAssertEqual(1, shareablesResponse?.count)
        XCTAssertEqual("refer-a-friend", shareablesResponse?.first?.label)
    }
    
    func testCustomShare() {
        let tokenResponse = extoleApi.getToken()
        let accessToken = tokenResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssert(accessToken != nil)
        XCTAssert(!accessToken!.access_token.isEmpty)
        let newShareable = ExtoleAPI.MyShareable(label: "refer-a-friend")
        let pollingResponse = extoleApi.createShareable(accessToken: accessToken!,
                                                        shareable: newShareable)
        let pollingResult = pollingResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertEqual("SUCCEEDED", pollingResult?.status)
        XCTAssertGreaterThan(pollingResult!.code, "1111")
    
        let customShare = ExtoleAPI.CustomShare(advocate_code: pollingResult!.code,
                                                channel: "EMAIL",
                                                message: "testmessage",
                                                recipient_email: "rtibin@extole.com",
                                                data: [:])
        
        let shareResponse = extoleApi.customShare(accessToken : accessToken!, share: customShare)
            .await(timeout: DispatchTime.now() + .seconds(100))
        
        shareResponse?.share_id
        
    }
    
    func testFetchZone() {
        let shareLinkResponse = extoleApi.fetchZone(accessToken: nil,
                                                    zone: "share_experience")
        let shareLink = shareLinkResponse.await(timeout: DispatchTime.now() + .seconds(100))
        XCTAssert(shareLink != nil)
        let linkData = String.init(data: shareLink!, encoding: String.Encoding.utf8)!
        Logger.Debug(message: "share_link : \(linkData)")
        XCTAssert(linkData.contains("extole.define"))
    }

}
