import XCTest
@testable import Wire

final class RequestModifiableTests: XCTestCase {
    func testSuccess() throws {
        let requestModifier = AnyRequestModifiable { req in
            var req = req
            req.httpMethod = HTTPMethod.post.value
            return .success(req)
        }
        let origReq = URLRequest(url: .demo)
        let newReq = try requestModifier.modify(origReq).get()

        XCTAssertEqual(origReq.url, newReq.url)
        XCTAssertEqual(origReq.httpMethod, "GET")
        XCTAssertEqual(newReq.httpMethod, "POST")
    }

    func testFailure() {
        let requestModifier = AnyRequestModifiable(FailureModifier())

        XCTAssertThrowsError(try requestModifier.modify(URLRequest(url: .demo)).get(), "") { error in
            XCTAssertEqual(error as? TestError, .failure)
        }
    }

    func testSetHeaders() throws {
        let modifier = SetHeaderModifier(headers: ["Foo": "Bar"])
        let origReq = URLRequest(url: .demo)
        let newReq = try modifier.modify(origReq).get()

        XCTAssertEqual(newReq.allHTTPHeaderFields, ["Foo": "Bar"])
    }

    func testSetBody() throws {
        let modifier = SetBodyModifier(body: .demo)
        let origReq = URLRequest(url: .demo)
        let newReq = try modifier.modify(origReq).get()

        XCTAssertEqual(newReq.httpBody, .demo)
    }
}

private struct FailureModifier: RequestModifiable {
    func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        return .failure(TestError.failure)
    }
}

private struct SetHeaderModifier: RequestModifiable {
    let headers: [String: String]

    func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        var req = request
        set(headers: headers, to: &req)
        return .success(req)
    }
}

private struct SetBodyModifier: RequestModifiable {
    let body: Data?

    func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        var req = request
        set(body: body, to: &req)
        return .success(req)
    }
}
