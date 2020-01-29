//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class ZoneResponseTest: XCTestCase {

    func testDecodeString() {
        let empty: Data = "{\"event_id\":\"123\", \"data\":{\"str\": \"val\"}}".data(using: .utf8)!
        let emptyResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: empty)
        XCTAssertEqual("val", emptyResponse.data["str"])
    }
    
    func testDecodeNumber() {
        let empty: Data = "{\"event_id\":\"123\", \"data\":{\"number\": 1.5}}".data(using: .utf8)!
        let emptyResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: empty)
        XCTAssertEqual("1.5", emptyResponse.data["number"])
    }
    
    func testDecodeInt() {
        let empty: Data = "{\"event_id\":\"123\", \"data\":{\"int\": 1}}".data(using: .utf8)!
        let emptyResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: empty)
        XCTAssertEqual("1", emptyResponse.data["int"])
    }
    
    func testDecodeArray() {
        let empty: Data = "{\"event_id\":\"123\", \"data\":{\"arr\": [1,2,3,11]}}".data(using: .utf8)!
        let emptyResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: empty)
        XCTAssertEqual("4", emptyResponse.data["arr"])
    }
    
    func testDecodeArrayItem() {
        let empty: Data = "{\"event_id\":\"123\", \"data\":{\"arr\": [1,2,3,11]}}".data(using: .utf8)!
        let emptyResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: empty)
        XCTAssertEqual("1", emptyResponse.data["arr.0"])
        XCTAssertEqual("2", emptyResponse.data["arr.1"])
        XCTAssertEqual("3", emptyResponse.data["arr.2"])
        XCTAssertEqual("11", emptyResponse.data["arr.3"])
    }
    
    func testDecodeArrayObject() {
        let empty: Data = "{\"event_id\":\"123\", \"data\":{\"arr\": [{\"a\":1}]}}".data(using: .utf8)!
        let emptyResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: empty)
        XCTAssertEqual("1", emptyResponse.data["arr.0.a"])
    }
    
    func testDecodeBool() {
        let empty: Data = "{\"event_id\":\"123\", \"data\":{\"result\": true}}".data(using: .utf8)!
        let emptyResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: empty)
        XCTAssertEqual("true", emptyResponse.data["result"])
    }
    
    func testDecodeObject() {
        let empty: Data = "{\"event_id\":\"123\", \"data\":{\"obj\": {\"att\" : true}}}".data(using: .utf8)!
        let emptyResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: empty)
        XCTAssertEqual("true", emptyResponse.data["obj.att"])
    }
    
    func testDecodeEmpty() {
        let empty: Data = "{\"event_id\":\"123\", \"data\":{}}".data(using: .utf8)!
        let emptyResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: empty)
        XCTAssertNil(emptyResponse.data["empty"])
    }

}
