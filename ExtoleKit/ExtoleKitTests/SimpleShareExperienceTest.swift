//Copyright © 2019 Extole. All rights reserved.

import XCTest
@testable import ExtoleKit

class SimpleShareExperienceTest: XCTestCase {

    struct Settings : Codable {
        let shareMessage: String
    }

    func testSignalShare() {
        let promise = expectation(description: "invalid share response")
        let shareApp = ExtoleShareExperince(programUrl: URL.init(string: "https://ios-santa.extole.io")!, programLabel: "refer-a-friend")
        shareApp.reset()
        let share = CustomShare(channel:"test")
        shareApp.notify(share: share, success: { (CustomSharePollingResult) in
            promise.fulfill();
        }, error :{ (error) in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFailedShare() {
        let promise = expectation(description: "invalid share response")
        let shareApp = ExtoleShareExperince(programUrl: URL.init(string: "https://ios-santa-missing.extole.io")!, programLabel: "missing")
        shareApp.reset()
        
        shareApp.notify(share: CustomShare(channel:"test"), success: { (CustomSharePollingResult) in
            XCTFail("unexpected success")
        }) { (error) in
            XCTAssertEqual("reset", error.code)
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchSettings() {
        let promise = expectation(description: "settings response")
        let shareApp = ExtoleShareExperince(programUrl: URL.init(string: "https://ios-santa.extole.io")!, programLabel: "missing")
        shareApp.reset()
        
        shareApp.fetchObject(zone: "settings", success: { (settings: Settings) in
             promise.fulfill()
        }, error: { (error) in
             XCTFail("unexpected error " + error.code)
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSignal() {
        let promise = expectation(description: "conversion response")
        let shareApp = ExtoleShareExperince(programUrl: URL.init(string: "https://ios-santa.extole.io")!, programLabel: "missing")
        shareApp.reset()
        let parameters : [URLQueryItem] = [
            URLQueryItem(name: "cart_value", value: "12.31")
        ]
        shareApp.signal(zone: "conversion", parameters: parameters, success: {
            promise.fulfill()
        }, error: { (error) in
            XCTFail("unexpected error " + error.code)
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
}

