#if canImport(Combine)
import Combine
#endif
import Foundation
import XCTest
@testable import Wire

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
final class RequestPublisherTests: XCTestCase {
    private let client = DataTaskClient(session: .testing)
    private var bag: Set<AnyCancellable> = []

    override func tearDown() {
        TestURLProtocol.clearHandlers()
        bag.removeAll()
    }

    func testDataPublisher() {
        TestURLProtocol.setHandler(request: URLRequest(url: .demo)) { req in
            return ("OK".data(using: .utf8), HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        }

        let promise = expectation(description: #function)
        let request = Request<Data>(requestFactory: URL.demo, requestModifiers: [HTTPMethod.get])
        request.dataPublisher(using: client)
            .sink(receiveCompletion: { _ in }) { data in
                XCTAssertEqual(data.utf8String(or: ""), "OK")
                promise.fulfill()
            }
            .store(in: &bag)

        wait(for: [promise], timeout: 10.0)
    }

    func testObjectPublisher() {
        TestURLProtocol.setHandler(request: URLRequest(url: .demo)) { req in
            let objectData = try! JSONEncoder().encode(TestCodableObj.success)
            return (objectData, HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        }

        let promise = expectation(description: #function)
        let request = Request<TestCodableObj>(requestFactory: URL.demo, requestModifiers: [HTTPMethod.get], responseConverter: JSONConverter())
        request.objectPublisher(using: client)
            .sink(receiveCompletion: { _ in }) { object in
                XCTAssertEqual(object.description, TestCodableObj.success.description)
                promise.fulfill()
            }
            .store(in: &bag)

        wait(for: [promise], timeout: 10.0)
    }
}
