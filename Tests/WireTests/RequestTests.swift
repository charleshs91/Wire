import XCTest
@testable import Wire

final class RequestTests: XCTestCase {
    private let client = DataTaskClient(session: .testing)

    override func tearDown() {
        TestURLProtocol.clearHandlers()
    }

    func testRequestBuildable() throws {
        let request = Request<Data>(builder: URLRequest(url: .demo))
        let urlRequest = try request.buildRequest().get()

        XCTAssertEqual(urlRequest.url, URL.demo)
    }

    func testRequestModifiers() throws {
        let request = Request<Data>(
            builder: URLRequest(url: .demo),
            requestModifiers: [
                AnyRequestModifier { req in
                    var req = req
                    req.httpMethod = "PUT"
                    return .success(req)
                },
                ContentType.plainText,
                AnyRequestModifier { req in
                    var req = req
                    req.httpBody = #function.data(using: .utf8)
                    return .success(req)
                },
            ]
        )
        let urlRequest = try request.buildRequest().get()

        XCTAssertEqual(urlRequest.httpMethod, "PUT")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: ContentType.plainText.key), ContentType.plainText.value)
        XCTAssertEqual(urlRequest.httpBody, #function.data(using: .utf8))
    }

    func testDataModifiers() throws {
        let request = Request<Data>(
            builder: URLRequest(url: .demo),
            dataModifiers: [AnyDataModifier(Base64Modifier())]
        )
        let payload = "OK".data(using: .utf8)

        TestURLProtocol.setHandler(request: try request.buildRequest().get()) { req in
            return (payload, HTTPURLResponse(url: .demo, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        }

        let promise = expectation(description: #function)
        request.retrieveData(using: client) { result in
            XCTAssertEqual(try? result.get(), payload?.base64EncodedData())
            promise.fulfill()
        }

        wait(for: [promise], timeout: 10.0)
    }

    func testDataConverter() throws {
        let request = Request<TestCodableObj>(
            builder: URLRequest(url: .demo),
            responseConverter: JSONDecodingConverter<TestCodableObj>()
        )

        TestURLProtocol.setHandler(request: try request.buildRequest().get()) { req in
            let objectData = try! JSONEncoder().encode(TestCodableObj.success)
            return (objectData, HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        }

        let promise = expectation(description: #function)
        request.retrieveObject(using: client) { result in
            let object = try? result.get()
            XCTAssertNotNil(object)
            XCTAssertEqual(object?.description, TestCodableObj.success.description)
            promise.fulfill()
        }

        wait(for: [promise], timeout: 10.0)
    }
}

private struct Base64Modifier: DataModifiable {
    func modify(_ input: Data) -> Result<Data, Error> {
        return .success(input.base64EncodedData())
    }
}
