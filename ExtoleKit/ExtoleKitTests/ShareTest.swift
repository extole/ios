//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class ShareTest: XCTestCase {

    let program = Program(baseUrl: URL.init(string: "https://ios-santa.extole.io")!)
    var programSession: ProgramSession!
    var advocateCode: String?
    
    override func setUp() {
        let promise = expectation(description: "invalid token response")
        program.getToken(success: { token in
            XCTAssert(token != nil)
            XCTAssert(!token!.access_token.isEmpty)
            self.programSession = ProgramSession.init(program: self.program, token: token!)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        let createShareablePromise = expectation(description: "create shareable response")
        let newShareable = MyShareable.init(label: "refer-a-friend")
        var shareableResult: PollingIdResponse!
        programSession.createShareable(shareable: newShareable,
                                       success: { response in
            shareableResult = response!
            createShareablePromise.fulfill()
        }, error: { error in
            XCTAssertNil(error)
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertGreaterThan(shareableResult.polling_id, "111111")
        
        let pollShareablePromise = expectation(description: "poll shareable response")
        programSession.pollShareable(pollingResponse: shareableResult!,
                                     success: { result in
            self.advocateCode = result!.code!
            pollShareablePromise.fulfill()
        }, error: { error in
            XCTAssertNil(error)
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCustomShare() {
        let customShare = CustomShare(advocate_code: advocateCode!,
                                      channel: "test",
                                      message: "testmessage",
                                      recipient_email: "rtibin@extole.com",
                                      data: [:])
        
        let shareExpectation = expectation(description: "share")
        var sharePollingId : PollingIdResponse!
        programSession.customShare(share: customShare, success: { shareResponse in
            XCTAssertGreaterThan(shareResponse!.polling_id, "1111")
            sharePollingId = shareResponse!
            shareExpectation.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })

        wait(for: [shareExpectation], timeout: 10)

        let pollingExpectation = expectation(description: "share polling")
        programSession.pollCustomShare(pollingResponse: sharePollingId, success: { customShareResult in
            XCTAssertGreaterThan(customShareResult!.share_id, "1111")
            pollingExpectation.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        wait(for: [pollingExpectation], timeout: 10)

    }

}
