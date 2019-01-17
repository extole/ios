//
//  firstappTests.swift
//  firstappTests
//
//  Created by rtibin on 1/11/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import XCTest

@testable import firstapp

class firstappTests: XCTestCase {

    let extoleApi = ExtoleAPI.init(baseUrl: "https://roman-tibin-test.extole.com")
    let waitGroup = DispatchGroup.init()
    
    override func setUp() {
        waitGroup.enter()
        Logger.Info(message: "setup")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
         Logger.Info(message: "teardown")
    }

    func testGetToken() {
        Logger.Info(message: "start load")
        extoleApi.getToken() { token in
            Logger.Info(message: "Received \(token)")
            self.waitGroup.leave()
        }
        waitGroup.wait(timeout: DispatchTime.now() + .seconds(10))
    }

}
