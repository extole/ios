//Copyright © 2019 Extole. All rights reserved.

import Foundation

import XCTest
import ExtoleAPI

@testable import ExtoleApp

class SessionBuilderTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")

    func newBuilder() -> ExtoleApp.SessionBuilder {
        return extoleAPI.sessionBuilder { e in
            XCTFail(e.error.code)
        }
    }

    public func testNewSession() {
        let sessionBuilder = newBuilder()
        let created = expectation(description: "new session")
        sessionBuilder.build(success: { newSession in
            created.fulfill()
        })
        wait(for: [created], timeout: 5)
    }
    
    public func testResume() {
        let sessionBuilder = newBuilder()
        let created = expectation(description: "new session")
        var accessToken : String? = nil
        sessionBuilder.build{ newSession in
            accessToken = newSession.accessToken
            created.fulfill()
        }
        wait(for: [created], timeout: 5)
        
        let resumeBuilder = newBuilder()
        
        let resumed = expectation(description: "resumed session")
        resumeBuilder.resume(accessToken: accessToken ?? "empty").build { session in
            XCTAssertEqual(accessToken, session.accessToken)
            resumed.fulfill()
        }
        wait(for: [resumed], timeout: 5)
    }
    
    public func testInvalid() {
        let sessionBuilder = newBuilder()
        let resumed = expectation(description: "resumed session")
        sessionBuilder.resume(accessToken: "invalid").build { session in
            resumed.fulfill()
            XCTAssertNotNil(session.accessToken)
        }
        wait(for: [resumed], timeout: 5)
    }
    
    public func testCreateWithEmail() {
        let advocateEmail = String(format: "adv-%lu@extole.com", mach_absolute_time())
        
        let sessionBuilder = newBuilder()
        let resumed = expectation(description: "resumed session")
        var sessionWithEmail: ExtoleAPI.Session!
        
        sessionBuilder.identify(email: advocateEmail).build { session in
            XCTAssertNotNil(session.accessToken)
            sessionWithEmail = session
            resumed.fulfill()
        }
        wait(for: [resumed], timeout: 5)
        //
        let profileVerified = expectation(description: "resumed session")
        sessionWithEmail.getProfile(success: { me in
            XCTAssertEqual(advocateEmail, me.email)
            profileVerified.fulfill()
        }, error: { e in
            XCTFail(e.code)
        })
        wait(for: [profileVerified], timeout: 5)
    }
}
