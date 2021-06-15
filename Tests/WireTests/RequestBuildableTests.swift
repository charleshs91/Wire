import XCTest
@testable import Wire

final class RequestBuildableTests: XCTestCase {
    func testURLRequest() throws {
        let urlRequest = URLRequest(url: .demo)
        let req = urlRequest.buildRequest()

        XCTAssertEqual(try req.get(), urlRequest)
    }

    func testURL() throws {
        let req = URL.demo.buildRequest()

        XCTAssertEqual(try req.get().url, URL.demo)
    }

    func testValidString() throws {
        let req = String.validURLString.buildRequest()

        XCTAssertEqual(try req.get().url?.absoluteString, .validURLString)
    }

    func testInvalidURLString() {
        for urlString in String.invalidURLStrings {
            let req = urlString.buildRequest()

            XCTAssertThrowsError(try req.get(), "") { error in
                XCTAssertTrue(error as? BaseError == .invalidURLString(urlString))
            }
        }
    }
}
