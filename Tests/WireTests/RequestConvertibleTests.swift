import XCTest
@testable import Wire

final class RequestConvertibleTests: XCTestCase {
    func testURLRequest() {
        let urlRequest = URLRequest(url: .demo)
        let req = urlRequest.buildRequest()
        XCTAssertNoThrow(try req.get())
        XCTAssertEqual(try! req.get(), urlRequest)
    }

    func testURL() {
        let req = URL.demo.buildRequest()
        XCTAssertNoThrow(try req.get())
        XCTAssertEqual(try! req.get().url, URL.demo)
    }

    func testValidString() {
        let req = String.validURLString.buildRequest()
        XCTAssertNoThrow(try req.get())
        XCTAssertEqual(try! req.get().url?.absoluteString, String.validURLString)
    }

    func testInvalidURLString() {
        for urlString in String.invalidURLStrings {
            let req = urlString.buildRequest()
            XCTAssertThrowsError(try req.get(), "") { error in
                XCTAssertTrue(error as? Wire.BaseError == .invalidURLString(urlString))
            }
        }
    }
}
