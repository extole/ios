import XCTest
@testable import ExtoleApp

final class ExtoleAppTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ExtoleApp().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
