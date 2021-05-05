#if canImport(Combine)
import Combine
#endif
import Foundation
import XCTest
@testable import Wire

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
final class ResourcePublisherTests: XCTestCase {
    private let client = DataTaskClient(session: .testing)
    private var disposables: Set<AnyCancellable> = []

    override func tearDown() {
        TestURLProtocol.clearHandlers()
        disposables.removeAll()
    }

    func testDataPublisher() {
        TestURLProtocol.setHandler(request: URLRequest(url: .demo)) { req in
            return ("OK".data(using: .utf8), HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        }

        let promise = expectation(description: #function)
        Resource(url: .demo, method: .get, headers: [], body: nil).dataPublisher(client: client)
            .sink(receiveCompletion: { _ in promise.fulfill() }) { data in
                XCTAssertEqual(data.utf8String(or: ""), "OK")
            }
            .store(in: &disposables)

        wait(for: [promise], timeout: 10.0)
    }

    func testObjectPublisher() {
        TestURLProtocol.setHandler(request: URLRequest(url: .demo)) { req in
            let objectData = try! JSONEncoder().encode(TestCodableObj.success)
            return (objectData, HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        }

        let promise = expectation(description: #function)
        Resource(url: .demo, method: .get, headers: [], body: nil).objectPublisher(client: client, asType: TestCodableObj.self)
            .sink(receiveCompletion: { _ in promise.fulfill() }) { object in
                XCTAssertEqual(object.description, TestCodableObj.success.description)
            }
            .store(in: &disposables)

        wait(for: [promise], timeout: 10.0)
    }
}
