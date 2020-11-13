import XCTest
@testable import LeakDetector

final class LeakDetectorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LeakDetector().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
