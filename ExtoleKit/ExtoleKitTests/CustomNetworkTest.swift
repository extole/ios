//Copyright © 2019 Extole. All rights reserved.

import Foundation
import XCTest
@testable import ExtoleKit

class CustomNetworkTest : XCTestCase {
    
    class CustomNetwork: Network {
        override func processRequest<T, E>(with request: URLRequest,
                                           success: @escaping (T?) -> Void,
                                           error: @escaping (E) -> Void)
            where T : Decodable, T : Encodable, E : ExtoleError {
                let token = ConsumerToken(access_token: "custom")
                success(token as! T)
        }
    }
    
    static func virtualProgram() -> Program {
        let network = CustomNetwork()
        
        let program = Program(baseUrl: URL.init(string: "https://virtual.extole.io")!,
            network: network)
        
        return program
    }
    
    let program = virtualProgram()
    
    func testGetToken() {
        let promise = expectation(description: "get token response")
        program.getToken(success: { token in
            XCTAssertEqual("custom", token?.access_token)
            promise.fulfill()
        }, error: { error in
            XCTFail(String(reflecting: error))
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
}
