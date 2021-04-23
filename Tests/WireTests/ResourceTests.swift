import XCTest
@testable import Wire

final class ResourceTests: XCTestCase {
    func testInitWithURL() {
        let res = Resource(url: .demo,
                           headers: [.contentType(.json),
                                     .userAgent("iPhone"),
                                     .authorization(.other("Auth")),
                                     .other(key: "OtherKey", value: "OtherValue")],
                           method: .get,
                           body: .demo)
        XCTAssertNoThrow(try res.buildRequest().get())
        let req = try! res.buildRequest().get()
        XCTAssertEqual(req.url?.absoluteString, URL.demo.absoluteString)
        XCTAssertEqual(req.httpMethod, "GET")
        XCTAssertEqual(
            req.allHTTPHeaderFields,
            [HTTP.Header.contentType(.json).key: HTTP.Header.contentType(.json).value,
             HTTP.Header.userAgent("iPhone").key: "iPhone",
             HTTP.Header.authorization(.other("Auth")).key: "Auth",
             "OtherKey": "OtherValue"]
        )
        XCTAssertEqual(req.httpBody, Data.demo)
    }

    func testInitWithString() {
        let res = Resource(urlString: .validURLString, headers: [.authorization(.bearer("Token"))])
        XCTAssertNotNil(res)
        let req = try! res!.buildRequest().get()
        XCTAssertEqual(req.url?.absoluteString, String.validURLString)
        XCTAssertTrue(req.allHTTPHeaderFields?[HTTP.Header.authorization(.bearer("Token")).key]?.starts(with: "Bearer ") ?? false)
    }

    func testInitWithInvalidString() {
        for urlString in String.invalidURLStrings {
            XCTAssertNil(Resource(urlString: urlString))
        }
    }
}
