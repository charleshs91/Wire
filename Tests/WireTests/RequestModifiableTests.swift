import XCTest
@testable import Wire

final class RequestModifiableTests: XCTestCase {
    func testInit() {
        let requestModifier = RequestModifier { req -> Result<URLRequest, Error> in
            var req = req
            req.httpMethod = HTTPMethod.post.value
            return .success(req)
        }
        let origRequest = URLRequest(url: .demo)
        let newRequest = try? requestModifier.modify(origRequest).get()
        XCTAssertEqual(origRequest.url, newRequest?.url)
        XCTAssertEqual(origRequest.httpMethod, "GET")
        XCTAssertEqual(newRequest?.httpMethod, "POST")
    }

    func testFailure() {
        let requestModifier = RequestModifier(StubModifier())
        XCTAssertThrowsError(try requestModifier.modify(URLRequest(url: .demo)).get(), "") { error in
            XCTAssertEqual(error as? TestError, .failure)
        }
    }

    func testSetHeaders() {
        let modifier = RequestHeaderModifier(headers: ["Foo": "Bar"])
        let origRequest = URLRequest(url: .demo)
        let newRequest = try? modifier.modify(origRequest).get()
        XCTAssertEqual(newRequest?.allHTTPHeaderFields, ["Foo": "Bar"])
    }

    func testSetBody() {
        let modifier = RequestBodyModifier(body: .demo)
        let origRequest = URLRequest(url: .demo)
        let newRequest = try? modifier.modify(origRequest).get()
        XCTAssertEqual(newRequest?.httpBody, .demo)
    }
}

private struct StubModifier: RequestModifiable {
    func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        return .failure(TestError.failure)
    }
}

private struct RequestHeaderModifier: RequestModifiable {
    let headers: [String: String]

    func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        var req = request
        set(headers: headers, to: &req)
        return .success(req)
    }
}

private struct RequestBodyModifier: RequestModifiable {
    let body: Data?

    func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        var req = request
        set(body: body, to: &req)
        return .success(req)
    }
}
