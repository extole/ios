//Copyright © 2019 Extole. All rights reserved.

import Foundation
import XCTest

@testable import ExtoleAPI

class PersonTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")
    var myProfile: ExtoleAPI.Me.MyProfileResponse!
    
    override func setUp() {
        let sessionCreated = expectation(description: "invalid token response")
        var mySession: ExtoleAPI.Session!
        extoleAPI.createSession(success: { session in
            mySession = session
            sessionCreated.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        wait(for: [sessionCreated], timeout: 5)
        
        let profileFetched = expectation(description: "fetch profile")
        mySession.getProfile(success: { myProfile in
            self.myProfile = myProfile
            profileFetched.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [profileFetched], timeout: 5)
        
        let profileUpdated = expectation(description: "update profile")
        mySession.updateProfile(first_name: "John",
                                success: {
            profileUpdated.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [profileUpdated], timeout: 5)
        
        let publicParametersUpdated = expectation(description: "update public parameters")
        mySession.updatePublicProfileParameters(parameters: [
            "favorite-color": "blue"
        ], success: {
            publicParametersUpdated.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [publicParametersUpdated], timeout: 5)
        
        let privateParametersUpdated = expectation(description: "update private parameters")
        mySession.updatePrivateProfileParameters(parameters: [
            "ssn": "234142012"
        ], success: {
            privateParametersUpdated.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [privateParametersUpdated], timeout: 5)
        
    }
    
    public func testGetPublicPerson() {
        let sessionCreated = expectation(description: "session created")
        var mySession: ExtoleAPI.Session!
        extoleAPI.createSession(success: { session in
            mySession = session
            sessionCreated.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [sessionCreated], timeout: 5)
        
        let profileFetched = expectation(description: "profile fetched")
        mySession.getPublicPerson(personId: myProfile.id,
                                  success: { person in
            XCTAssertEqual("John", person.first_name)
            XCTAssertEqual(["favorite-color":"blue"], person.parameters)
            profileFetched.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        
        wait(for: [profileFetched], timeout: 5)
    }
    
    public func testPersonNotFound() {
        let sessionCreated = expectation(description: "session created")
        var mySession: ExtoleAPI.Session!
        extoleAPI.createSession(success: { session in
            mySession = session
            sessionCreated.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [sessionCreated], timeout: 5)
        
        let profileNotFound = expectation(description: "profile not found")
        mySession.getPublicPerson(personId: "not_found",
                                  success: { profile in
            XCTFail("unexpected success")
            
        }, error: { e in
            XCTAssertEqual("invalid_person_id", e.code)
            profileNotFound.fulfill()
        })
        
        wait(for: [profileNotFound], timeout: 5)
    }
}
