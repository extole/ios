//
//  ShareTest.swift
//  firstappTests
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import XCTest

@testable import firstapp

class ShareTest: XCTestCase {

    let program = Program(baseUrl: "https://roman-tibin-test.extole.com")
    var accessToken: ConsumerToken?
    var advocateCode: String?
    
    override func setUp() {
        let tokenResponse = program.getToken().await(timeout: DispatchTime.now() + .seconds(10))
        self.accessToken = tokenResponse
        XCTAssert(accessToken != nil)
        XCTAssert(!accessToken!.access_token.isEmpty)
        
        let newShareable = MyShareable.init(label: "refer-a-friend")
        let shareableResponse = program.createShareable(accessToken: accessToken!,
                                                        shareable: newShareable)
        let shareableResult = shareableResponse.await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertGreaterThan(shareableResult!.polling_id, "111111")
        
        let pollingResult = program.pollShareable(accessToken: accessToken!,
                                                  pollingResponse: shareableResult!)
            .await(timeout: DispatchTime.now() + .seconds(10))
        advocateCode = pollingResult!.code!
    }
    
    func testCustomShare() {
        let customShare = CustomShare(advocate_code: advocateCode!,
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

}
