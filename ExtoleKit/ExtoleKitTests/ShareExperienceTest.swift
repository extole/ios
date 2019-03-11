//Copyright © 2019 Extole. All rights reserved.

import XCTest
import ExtoleKit

class ShareExperienceTest: XCTestCase {

    func testSignalShare() {
        let promise = expectation(description: "invalid token response")
        let shareApp = MyShareExperince();
        shareApp.signalShare(channel: "test", success: { (CustomSharePollingResult) in
            promise.fulfill();
        }) { (error) in
            XCTFail(String(reflecting: error))
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

class MyShareExperince: HasShareApp, ShareExperience {
    var shareApp = ExtoleShareApp.init(programUrl: URL.init(string: "https://ios-santa.extole.io")!, programLabel: "refer-a-friend", delegate: nil)
}
