import Foundation
import XCTest
@testable import Wire

final class DataTaskClientTests: XCTestCase {
    private let client = DataTaskClient(session: .testing)

    override func tearDown() {
        TestURLProtocol.clearHandlers()
    }

    func testInit() {
        let configuration = URLSessionConfiguration.background(withIdentifier: #function)
        configuration.httpMaximumConnectionsPerHost = 63
        let queue = OperationQueue()
        let dataTaskClient = DataTaskClient(configuration: configuration, delegateQueue: queue)
        XCTAssertEqual(dataTaskClient.session.configuration.identifier, #function)
        XCTAssertEqual(dataTaskClient.session.configuration.httpMaximumConnectionsPerHost, 63)
        XCTAssertEqual(dataTaskClient.session.delegateQueue, queue)
    }

    func testNoResponseFailure() {
        let promise = expectation(description: #function)

        TestURLProtocol.setHandler(request: URLRequest(url: .noResponse)) { req in
            return (nil, nil, nil)
        }
        client.retrieveData(request: Resource(url: .noResponse, method: .get, headers: [], body: nil)) { result in
            XCTAssertEqual(result.error as? BaseError, .noResponse)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10.0)
    }

    func testNotHTTPResponseFailure() {
        let promise = expectation(description: #function)

        let urlResponse = URLResponse(url: .noResponse, mimeType: nil, expectedContentLength: 1024, textEncodingName: nil)
        TestURLProtocol.setHandler(request: URLRequest(url: .notHTTP)) { req in
            return (nil, urlResponse, nil)
        }
        client.retrieveData(request: Resource(url: .notHTTP, method: .get, headers: [], body: nil)) { result in
            XCTAssertEqual(result.error as? BaseError, .notHttpResponse(response: urlResponse))
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10.0)
    }

    func testStatusCodeFailure() {
        let promise = expectation(description: #function)

        TestURLProtocol.setHandler(request: URLRequest(url: .statusCode(401))) { req in
            return (Data(), HTTPURLResponse(url: .statusCode(401), statusCode: 401, httpVersion: nil, headerFields: nil), nil)
        }
        client.retrieveData(request: Resource(url: .statusCode(401), method: .get, headers: [], body: nil)) { result in
            XCTAssertEqual(result.error as? BaseError, .httpStatus(code: 401, data: Data()))
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10.0)
    }
}
