import XCTest
@testable import Wire

final class RequestTests: XCTestCase {
    func testRequestBuildable() {
        let request = Request<Data>(requestBuilder: URLRequest(url: .demo), conversion: { data in data })
        let urlRequest = try? request.buildRequest().get()
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.url, URL.demo)
    }

    func testRequestModifiers() {
        let request = Request<Data>(
            requestBuilder: URLRequest(url: .demo),
            requestModifiers: [
                RequestModifier(closure: { req -> Result<URLRequest, Error> in
                    var req = req
                    req.httpMethod = "PUT"
                    return .success(req)
                }),
                RequestModifier(closure: { req -> Result<URLRequest, Error> in
                    var req = req
                    req.httpBody = #function.data(using: .utf8)
                    return .success(req)
                })
            ],
            dataModifiers: [],
            conversion: { data in data }
        )
        let urlRequest = try? request.buildRequest().get()
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.httpMethod, "PUT")
        XCTAssertEqual(urlRequest?.httpBody, #function.data(using: .utf8))
    }
}
