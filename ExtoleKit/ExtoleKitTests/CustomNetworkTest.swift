//Copyright © 2019 Extole. All rights reserved.

import Foundation
import XCTest
@testable import ExtoleKit

class CustomNetworkTest : XCTestCase {
    
    class CustomExecutor : NetworkExecutor {
        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
            let token = ConsumerToken(access_token: "custom_executor")
            let response = HTTPURLResponse.init(url: request.url!,
                                                statusCode: 200,
                                                httpVersion: "HTTP/1.1",
                                                headerFields: nil)
            let encoded = try? JSONEncoder().encode(token)
            completionHandler(encoded, response, nil)
        }
    }
    
    class CustomNetwork: Network {
        override func processRequest<T, E>(with request: URLRequest,
                                           success: @escaping (T?) -> Void,
                                           error: @escaping (E) -> Void)
            where T : Decodable, T : Encodable, E : ExtoleError {
                let token = ConsumerToken(access_token: "custom")
                success(token as? T)
        }
    }

    func testCustomToken() {
        let network = CustomNetwork()
        
        let program = Program(baseUrl: URL.init(string: "https://virtual.extole.io")!,
                              network: network)
        let promise = expectation(description: "get token response")
        program.getToken(success: { token in
            XCTAssertEqual("custom", token?.access_token)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDataToken() {
        let network = Network(executor: CustomExecutor())
        
        let program = Program(baseUrl: URL.init(string: "https://virtual.extole.io")!,
                              network: network)
        let promise = expectation(description: "get token response")
        program.getToken(success: { token in
            XCTAssertEqual("custom_executor", token?.access_token)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
}
