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
        
        self.programSession.createShareable(shareable: newShareable) { shareableResult, error in
            XCTAssertGreaterThan(shareableResult!.polling_id, "111111")
            shareableResponse = shareableResult!
            createShareablePromise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)

        var pollResponse : ShareablePollingResult!
        let pollShareablePromise = expectation(description: "poll shareable response")
        
        var shareableCode: String!
        
        self.programSession.pollShareable(pollingResponse: shareableResponse!) {
            result, error in
            pollResponse = result!
            shareableCode = pollResponse.code!
            
            XCTAssertGreaterThan(shareableCode, "1111")
            XCTAssertEqual(pollResponse?.status, "SUCCEEDED")
            
            pollShareablePromise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    
        let listShareablesPromise = expectation(description: "list shareables response")

        self.programSession.getShareables() {
            result, error in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            XCTAssertEqual(1, result?.count)
            XCTAssertEqual("refer-a-friend", result?.first?.label)
            
            listShareablesPromise.fulfill()
        }
        
        let duplicateShareable = MyShareable(label:"refer-a-friend", code: shareableCode)
        var duplicatePollResult: PollingIdResponse!
        
        let createDuplicateShareablePromise = expectation(description: "create duplocate shareable response")
        self.programSession.createShareable(shareable: duplicateShareable) {
            response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            duplicatePollResult = response
            createDuplicateShareablePromise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        let pollDuplocateShareablePromise = expectation(description: "poll shareable response")
        self.programSession.pollShareable(pollingResponse: duplicatePollResult) {
            response, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.status, "FAILED")
            pollDuplocateShareablePromise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}
