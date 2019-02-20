//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class ShareableTest: XCTestCase {

    let program = ProgramURL(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
    var programSession: ConsumerSession!
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        program.getToken(success: { token in
            XCTAssert(token != nil)
            XCTAssert(!token!.access_token.isEmpty)
            self.programSession = ConsumerSession.init(program: self.program, token: token!)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
            
        waitForExpectations(timeout: 5, handler: nil)
    }


    func testCreateWithCode() {
        let newShareable = MyShareable.init(label: "refer-a-friend")
        let createShareablePromise = expectation(description: "create shareable response")
        var shareableResponse : PollingIdResponse!
        
        self.programSession.createShareable(shareable: newShareable, success: { shareableResult in
            XCTAssertGreaterThan(shareableResult!.polling_id, "111111")
            shareableResponse = shareableResult!
            createShareablePromise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)

        var pollResponse : ShareablePollingResult!
        let pollShareablePromise = expectation(description: "poll shareable response")
        
        var shareableCode: String!

        self.programSession.pollShareable(pollingResponse: shareableResponse!, success: { result in
            pollResponse = result!
            shareableCode = pollResponse.code!
            
            XCTAssertGreaterThan(shareableCode, "1111")
            XCTAssertEqual(pollResponse?.status, "SUCCEEDED")
            
            pollShareablePromise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    
        let listShareablesPromise = expectation(description: "list shareables response")

        self.programSession.getShareables(success: { result in
            XCTAssertNotNil(result)
            XCTAssertEqual(1, result?.count)
            XCTAssertEqual("refer-a-friend", result?.first?.label)
            listShareablesPromise.fulfill()
        }, error:  {
            error in
            XCTFail(String(reflecting: error))
        })
        
        let duplicateShareable = MyShareable(label:"refer-a-friend", code: shareableCode)
        var duplicatePollResult: PollingIdResponse!
        
        let createDuplicateShareablePromise = expectation(description: "create duplocate shareable response")
        self.programSession.createShareable(shareable: duplicateShareable, success: { response in
            XCTAssertNotNil(response)
            duplicatePollResult = response
            createDuplicateShareablePromise.fulfill()
        }, error: { error in
            XCTAssertNil(error)
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        let pollDuplocateShareablePromise = expectation(description: "poll shareable response")
        self.programSession.pollShareable(pollingResponse: duplicatePollResult,
                                          success: { response in
                                        XCTAssertEqual(response?.status, "FAILED")
                                        pollDuplocateShareablePromise.fulfill()
        }, error : { error in
            XCTAssertNil(error)
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
