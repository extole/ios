//Copyright © 2019 Extole. All rights reserved.

import XCTest
@testable import ExtoleKit

class SimpleShareExperienceTest: XCTestCase {

    func testSignalShare() {
        let promise = expectation(description: "invalid share response")
        let shareApp = SimpleShareExperince(programUrl: URL.init(string: "https://ios-santa.extole.io")!, programLabel: "refer-a-friend")
        shareApp.reset()
        shareApp.signalShare(channel: "test", success: { (CustomSharePollingResult) in
            promise.fulfill();
        }) { (error) in
            XCTFail(String(reflecting: error))
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFailedShare() {
        let promise = expectation(description: "invalid share response")
        let shareApp = SimpleShareExperince(programUrl: URL.init(string: "https://ios-santa-missing.extole.io")!, programLabel: "missing")
        shareApp.reset()
        
        shareApp.signalShare(channel: "test", success: { (CustomSharePollingResult) in
            XCTFail("unexpected success")
        }) { (error) in
            XCTAssertEqual("not_ready", error.code)
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

