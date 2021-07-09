import XCTest
@testable import Wire

final class RequestModifiableTests: XCTestCase {
    func testSuccess() throws {
        let requestModifier = AnyRequestModifier { req in
            var req = req
            req.httpMethod = HTTPMethod.post.method
            return .success(req)
        }
        let origReq = URLRequest(url: .demo)
        let newReq = try requestModifier.modify(origReq).get()

        XCTAssertEqual(origReq.url, newReq.url)
        XCTAssertEqual(origReq.httpMethod, "GET")
        XCTAssertEqual(newReq.httpMethod, "POST")
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
