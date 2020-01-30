//Copyright © 2019 Extole. All rights reserved.

import XCTest
@testable import ExtoleKit

class SimpleShareExperienceTest: XCTestCase {

    struct Settings : Codable {
        let shareMessage: String
    }

    func testSignalShare() {
        let promise = expectation(description: "invalid share response")
        let shareApp = ExtoleShareExperince(programDomain: "ios-santa.extole.io", programLabel: "refer-a-friend")
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
        let shareApp = ExtoleShareExperince(programDomain: "ios-santa-missing.extole.io", programLabel: "missing")
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
        let shareApp = ExtoleShareExperince(programDomain: "ios-santa.extole.io", programLabel: "missing")
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
        let shareApp = ExtoleShareExperince(programDomain: "ios-santa.extole.io", programLabel: "missing")
        shareApp.reset()
        let parameters : [String: String] = [
            "cart_value": "12.31"
        ]
        shareApp.signal(zone: "conversion", data: parameters, success: { response in
            XCTAssertNotNil(response.event_id)
            promise.fulfill()
        }, error: { (error) in
            XCTFail("unexpected error " + error.code)
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testUpdateProfile() {
        let updateProfile = expectation(description: "update profile")
        let shareApp = ExtoleShareExperince(programDomain: "ios-santa.extole.io", programLabel: "missing")
        shareApp.reset()
        let profile = MyProfile(first_name: "test profile")
        
        shareApp.update(profile: profile, success: {
            updateProfile.fulfill()
        }, error: { (error) in
            XCTFail("unexpected error " + error.code)
        })
        
        wait(for: [updateProfile], timeout: 5)
        let fetchProfile = expectation(description: "fetch profile")
        
        shareApp.async { (app) in
            app?.session?.getProfile(success: { (profile) in
                XCTAssertEqual("test profile", profile.first_name)
                fetchProfile.fulfill()
            }, error: { error in
                 XCTFail("unexpected error " + error.code)
            })
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}

