//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class MeTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")
    var extoleSession: ExtoleAPI.Session!
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        extoleAPI.createSession(success: { session in
            self.extoleSession = session
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    public func testGetShares() {
        let promise = expectation(description: "get shares")
        extoleSession.getShares(success: { shares in
            XCTAssertEqual(0, shares.count)
            promise.fulfill()
        }, error: { error in
            XCTFail(error.code)
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    public func testGetFriends() {
        let promise = expectation(description: "get friends")
        extoleSession.getAssociatedFriends(success: { friends in
            XCTAssertEqual(0, friends.count)
            promise.fulfill()
        }, error: { error in
            XCTFail(error.code)
        })
         waitForExpectations(timeout: 5, handler: nil)
    }
    
    public func testGetProfile() {
        let promise = expectation(description: "get profile")
        extoleSession.getProfile(success: { profile in
            XCTAssertNotNil(profile.id)
            promise.fulfill()
        }, error: { error in
            XCTFail(error.code)
        })
         waitForExpectations(timeout: 5, handler: nil)
    }
    
    public func testUpdateProfile() {
        let updatePromise = expectation(description: "update profile")
        extoleSession.updateProfile(first_name: "john",
            success: { status in
                XCTAssertEqual("success", status.status)
            updatePromise.fulfill()
        }, error: { error in
            XCTFail(error.code)
        })
        wait(for: [updatePromise], timeout: 5)
        
        let getPromise = expectation(description: "get profile")
        extoleSession.getProfile(success: { profile in
            XCTAssertNotNil(profile.id)
            XCTAssertEqual("john", profile.first_name)
            getPromise.fulfill()
        }, error: { error in
            XCTFail(error.code)
        })
        wait(for: [getPromise], timeout: 5)
    }
}
