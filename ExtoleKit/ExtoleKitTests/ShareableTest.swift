//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class ShareableTest: XCTestCase {

    let program = ExtoleAPI(programDomain: "ios-santa.extole.io")
    var programSession: ExtoleSession!
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        program.createSession(success: { session in
            self.programSession = session
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
            XCTAssertGreaterThan(shareableResult.polling_id, "111111")
            shareableResponse = shareableResult
            createShareablePromise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)

        let pollShareablePromise = expectation(description: "poll shareable response")
        
        var shareableCode: String!

        self.programSession.pollShareable(pollingResponse: shareableResponse!, success: { pollResponse in
            shareableCode = pollResponse.code!
            
            XCTAssertGreaterThan(shareableCode, "1111")
            XCTAssertEqual(pollResponse.status, "SUCCEEDED")
            
            pollShareablePromise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    
        let listShareablesPromise = expectation(description: "list shareables response")

        self.programSession.getShareables(success: { result in
            XCTAssertEqual(1, result.count)
            XCTAssertEqual("refer-a-friend", result.first?.label)
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
                                        XCTAssertEqual(response.status, "FAILED")
                                        pollDuplocateShareablePromise.fulfill()
        }, error : { error in
            XCTAssertNil(error)
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
