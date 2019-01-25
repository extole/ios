//
//  firstappTests.swift
//  firstappTests
//
//  Created by rtibin on 1/11/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import XCTest

@testable import firstapp

class ZoneTest: XCTestCase {

    let program = Program(baseUrl: "https://roman-tibin-test.extole.com")

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
