import XCTest
@testable import Wired

final class WiredTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Wired().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
