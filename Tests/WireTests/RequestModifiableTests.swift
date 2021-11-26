import XCTest
@testable import Wire

final class RequestModifiableTests: XCTestCase {
    func testSuccess() throws {
        let requestModifier = AnyRequestModifier { req in
            var req = req
            req.httpMethod = HTTPMethod.post.method
            return .success(req)
        }
        let request = URLRequest(url: .demo)
        let modifiedRequest = try requestModifier.modify(request).get()

        XCTAssertEqual(request.url, modifiedRequest.url)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(modifiedRequest.httpMethod, "POST")
    }

    func testFailure() {
        let requestModifier = AnyRequestModifier(FailureModifier())

        XCTAssertThrowsError(try requestModifier.modify(URLRequest(url: .demo)).get(), "") { error in
            XCTAssertEqual(error as? TestError, .failure)
        }
    }
}

private struct FailureModifier: RequestModifiable {
    func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        return .failure(TestError.failure)
    }
}
