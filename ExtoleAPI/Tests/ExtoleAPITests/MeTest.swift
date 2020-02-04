//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleAPI

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
    
    public func testGetRewards() {
        let promise = expectation(description: "get friends")
        extoleSession.getRewards(success: { rewards in
            XCTAssertEqual(0, rewards.count)
            promise.fulfill()
        }, error: { error in
            XCTFail(error.code)
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testIdentify() {
        let identify = expectation(description: "identify response")
        extoleSession.updateProfile(email: "testidentify@extole.com", success: {
            identify.fulfill()
        }, error : { error in
            XCTFail(String(reflecting: error))
        })
        
        wait(for: [identify], timeout: 10)
        
        let verifyIdentity = expectation(description: "verifyIdentity response")
        self.extoleSession.getProfile(success: { profile in
            XCTAssertEqual("testidentify@extole.com", profile.email)
            verifyIdentity.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
    
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testUpdateProfile() {
        let updatePromise = expectation(description: "update profile")
        extoleSession.updateProfile(first_name: "First",
                                    last_name: "Last",
                                    partner_user_id: "user-id"
            , success: {
                updatePromise.fulfill()
            }, error : { error in
                XCTFail(String(reflecting: error))
        })
    
        wait(for: [updatePromise], timeout: 5)
        
        let verifyUpdate = expectation(description: "verifyIdentity response")
        extoleSession.getProfile(success: { profile in
            XCTAssertEqual("user-id", profile.partner_user_id)
            XCTAssertEqual("First", profile.first_name)
            XCTAssertEqual("Last", profile.last_name)
            verifyUpdate.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUpdatePublicParameters() {
        let updatePromise = expectation(description: "update profile")
        let publicParameters: [String: String] = [
            "favorite-color": "yellow"
        ]
        extoleSession.updatePublicProfileParameters(parameters: publicParameters
            , success: {
                updatePromise.fulfill()
            }, error : { error in
                XCTFail(error.code)
        })
    
        wait(for: [updatePromise], timeout: 5)
        
        let verifyUpdate = expectation(description: "verifyIdentity response")
        extoleSession.getProfile(success: { profile in
            
            XCTAssertEqual(publicParameters, profile.parameters)
            verifyUpdate.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUpdatePrivateParameters() {
        let updatePromise = expectation(description: "update profile")
        let privateParameters: [String: String] = [
            "ssn": "3231234"
        ]
        extoleSession.updatePrivateProfileParameters(parameters: privateParameters
            , success: {
                updatePromise.fulfill()
            }, error : { error in
                XCTFail(error.code)
        })
    
        wait(for: [updatePromise], timeout: 5)
        
        let verifyUpdate = expectation(description: "verifyIdentity response")
        extoleSession.getProfile(success: { profile in
            
            XCTAssertEqual(privateParameters, profile.parameters)
            verifyUpdate.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}
