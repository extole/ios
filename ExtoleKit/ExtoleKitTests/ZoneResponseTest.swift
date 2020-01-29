//Copyright © 2019 Extole. All rights reserved.

import XCTest

@testable import ExtoleKit

class ZoneResponseTest: XCTestCase {

    func testDecodeString() {
        let stringData: Data = "{\"event_id\":\"123\", \"data\":{\"str\": \"val\"}}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: stringData)
        XCTAssertEqual("val", zoneResponse.data["str"])
    }
    
    func testDecodeNumber() {
        let numberData: Data = "{\"event_id\":\"123\", \"data\":{\"number\": 1.5}}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: numberData)
        XCTAssertEqual("1.5", zoneResponse.data["number"])
    }
    
    func testDecodeInt() {
        let intData: Data = "{\"event_id\":\"123\", \"data\":{\"int\": 1}}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: intData)
        XCTAssertEqual("1", zoneResponse.data["int"])
    }
    
    func testDecodeArray() {
        let arrayData: Data = "{\"event_id\":\"123\", \"data\": [1,2,3,11]}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: arrayData)
        XCTAssertEqual("4", zoneResponse.data[""])
        XCTAssertEqual("11", zoneResponse.data["3"])
    }
    
    func testDecodeArrayAttribute() {
        let arrayData: Data = "{\"event_id\":\"123\", \"data\":{\"arr\": [1,2,3,11]}}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: arrayData)
        XCTAssertEqual("4", zoneResponse.data["arr"])
    }
    
    func testDecodeArrayItem() {
        let arrayData: Data = "{\"event_id\":\"123\", \"data\":{\"arr\": [1,2,3,11]}}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: arrayData)
        XCTAssertEqual("1", zoneResponse.data["arr.0"])
        XCTAssertEqual("2", zoneResponse.data["arr.1"])
        XCTAssertEqual("3", zoneResponse.data["arr.2"])
        XCTAssertEqual("11", zoneResponse.data["arr.3"])
    }
    
    func testDecodeArrayObject() {
        let arrayData: Data = "{\"event_id\":\"123\", \"data\":{\"arr\": [{\"a\":1}]}}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: arrayData)
        XCTAssertEqual("1", zoneResponse.data["arr.0.a"])
    }
    
    func testDecodeBool() {
        let boolData: Data = "{\"event_id\":\"123\", \"data\":{\"result\": true}}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: boolData)
        XCTAssertEqual("true", zoneResponse.data["result"])
    }
    
    func testDecodeObject() {
        let objectData: Data = "{\"event_id\":\"123\", \"data\":{\"obj\": {\"att\" : true}}}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: objectData)
        XCTAssertEqual("true", zoneResponse.data["obj.att"])
    }
    
    func testDecodeNested() {
        let nestedData: Data = "{\"event_id\":\"123\", \"data\":[[[{\"obj\": {\"att\" : true}}]]]}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: nestedData)
        XCTAssertEqual("true", zoneResponse.data["0.0.0.obj.att"])
    }
    
    func testDecodeEmpty() {
        let emptyData: Data = "{\"event_id\":\"123\", \"data\":{}}".data(using: .utf8)!
        let zoneResponse = try! JSONDecoder().decode(ExtoleAPI.Zones.ZoneResponse.self,
                                                      from: emptyData)
        XCTAssertNil(zoneResponse.data["empty"])
    }

}
