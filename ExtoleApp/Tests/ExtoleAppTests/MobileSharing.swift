//Copyright © 2019 Extole. All rights reserved.

import Foundation
import XCTest
import ExtoleAPI

@testable import ExtoleApp

import Foundation

class MobileSharingTest: XCTestCase {

    let extoleAPI = ExtoleAPI(programDomain: "ios-santa.extole.io")

    var sessionManager: SessionManager!
    
    override func setUp() {
        super.setUp()
        sessionManager = extoleAPI.sessionManager()
    }
    
    public class CustomMobileSharing: Codable {
       public class Data: Codable {
         let me: [String: String]
       }
       let event_id: String
       let data: Data
    }
    
    public func testExtension() {
        let loaded = expectation(description: "load extended sharing")
        sessionManager.fetchMobileSharing { (custom: CustomMobileSharing) in
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 5)
        
    }
}
