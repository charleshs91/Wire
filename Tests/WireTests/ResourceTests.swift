import Foundation
import XCTest
@testable import Wire

final class ResourceTests: XCTestCase {
    private let testingClient = DataTaskClient(session: .testing)

    override func tearDown() {
        TestURLProtocol.clearHandlers()
    }

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
            [HTTPHeader.contentType(.json).key: HTTPHeader.contentType(.json).value,
             HTTPHeader.userAgent("iPhone").key: "iPhone",
             HTTPHeader.authorization(.other("Auth")).key: "Auth",
             "OtherKey": "OtherValue"]
        )
        XCTAssertEqual(req.httpBody, Data.demo)
    }

    func testInitWithString() {
        let res = Resource(urlString: .validURLString, headers: [.authorization(.bearer("Token"))])
        XCTAssertNotNil(res)
        let req = try! res!.buildRequest().get()
        XCTAssertEqual(req.url?.absoluteString, String.validURLString)
        XCTAssertTrue(req.allHTTPHeaderFields?[HTTPHeader.authorization(.bearer("Token")).key]?.starts(with: "Bearer ") ?? false)
    }

    func testInitWithInvalidString() {
        for urlString in String.invalidURLStrings {
            XCTAssertNil(Resource(urlString: urlString))
        }
    }

    func testGetDataSuccess() {
        TestURLProtocol.setHandler(request: URLRequest(url: .demo)) { req in
            return (Data(), HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        }

        let promise = expectation(description: #function)
        Resource(url: .demo, headers: [], method: .get, body: nil).retrieveData(client: testingClient) { result in
            let data = try? result.get()
            XCTAssertNotNil(data)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10.0)
    }

    func testGetObjectSuccess() {
        TestURLProtocol.setHandler(request: URLRequest(url: .demo)) { req in
            let objectData = try! JSONEncoder().encode(TestCodableObj.success)
            return (objectData, HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        }

        let promise = expectation(description: #function)
        Resource(url: .demo, headers: [], method: .get, body: nil).retrieveObject(client: testingClient, ofType: TestCodableObj.self) { result in
            let object = try? result.get()
            XCTAssertNotNil(object)
            XCTAssertEqual(object?.description, TestCodableObj.success.description)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10.0)
    }

    func testGetDataFailure() {
        TestURLProtocol.setHandler(request: URLRequest(url: .demo)) { req in
            return (nil, nil, TestError.failure)
        }

        let promise = expectation(description: #function)
        Resource(url: .demo, headers: [], method: .get, body: nil).retrieveData(client: testingClient) { result in
            XCTAssertEqual(result.error as? BaseError, .sessionError(TestError.failure))
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10.0)
    }
}
