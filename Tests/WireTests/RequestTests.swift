import XCTest
@testable import Wire

final class RequestTests: XCTestCase {
    func testRequestBuildable() {
        let request = Request<Data>(requestFactory: URLRequest(url: .demo), conversion: { data in data })
        let urlRequest = try? request.buildRequest().get()
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.url, URL.demo)
    }

    func testRequestModifiers() {
        let request = Request<Data>(
            requestFactory: URLRequest(url: .demo),
            requestModifiers: [
                AnyRequestModifiable(transform: { req -> Result<URLRequest, Error> in
                    var req = req
                    req.httpMethod = "PUT"
                    return .success(req)
                }),
                AnyRequestModifiable(transform: { req -> Result<URLRequest, Error> in
                    var req = req
                    req.httpBody = #function.data(using: .utf8)
                    return .success(req)
                })
            ],
            dataModifiers: []
        )
        let urlRequest = try? request.buildRequest().get()
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.httpMethod, "PUT")
        XCTAssertEqual(urlRequest?.httpBody, #function.data(using: .utf8))
    }
}
