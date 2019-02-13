//
//  ShareableTest.swift
//  firstappTests
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import XCTest

@testable import ExtoleKit

class ShareableTest: XCTestCase {

    let program = Program(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
    var programSession: ProgramSession!
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        program.getToken() { token, error in
            XCTAssert(token != nil)
            XCTAssert(!token!.access_token.isEmpty)
            self.programSession = ProgramSession.init(program: self.program, token: token!)
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }


    func testCreateWithCode() {
        let newShareable = MyShareable.init(label: "refer-a-friend")
        let createShareablePromise = expectation(description: "create shareable response")
        var shareableResponse : PollingIdResponse!
        
        programSession.createShareable(shareable: newShareable) { shareableResult, error in
            XCTAssertGreaterThan(shareableResult!.polling_id, "111111")
            shareableResponse = shareableResult!
            createShareablePromise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)

        var pollResponse : ShareablePollingResult!
        let pollShareablePromise = expectation(description: "poll shareable response")
        
        programSession.pollShareable(pollingResponse: shareableResponse!) {
            result, error in
            pollResponse = result!
            let shareableCode = pollResponse.code!
            
            XCTAssertGreaterThan(shareableCode, "1111")
            XCTAssertEqual(pollResponse?.status, "SUCCEEDED")
            
            pollShareablePromise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    
        
        let shareablesResponse = programSession.getShareables()
            .await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertNotNil(shareablesResponse)
        XCTAssertEqual(1, shareablesResponse?.count)
        XCTAssertEqual("refer-a-friend", shareablesResponse?.first?.label)
        
        let duplicateShareable = MyShareable(label:"refer-a-friend", code: shareableCode)
        
        let duplicateShareableResponse = program.createShareable(accessToken: accessToken!, shareable: duplicateShareable)
            .await(timeout: DispatchTime.now() + .seconds(10))
        
        let duplicatePollingResult = program.pollShareable(accessToken: accessToken!,
                                                           pollingResponse: duplicateShareableResponse!)
            .await(timeout: DispatchTime.now() + .seconds(10))
        XCTAssertEqual(duplicatePollingResult?.status, "FAILED")
        
    }

}
