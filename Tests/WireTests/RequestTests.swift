import XCTest
@testable import Wire

final class RequestTests: XCTestCase {
    private let client = DataTaskClient(session: .testing)

    override func tearDown() {
        TestURLProtocol.clearHandlers()
    }

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

    func testDataModifiers() {
        let request = Request<Data>(
            requestFactory: URLRequest(url: .demo),
            requestModifiers: [],
            dataModifiers: [AnyDataModifiable(Base64Modifier())]
        )

        TestURLProtocol.setHandler(request: try! request.buildRequest().get()) { req in
            return ("OK".data(using: .utf8), HTTPURLResponse(url: .demo, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        }
        let promise = expectation(description: #function)
        request.retrieveData(by: client) { result in
            let data = try? result.get()
            XCTAssertNotNil(data)
            XCTAssertEqual(data, "OK".data(using: .utf8)?.base64EncodedData())
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10.0)
    }

    func testDataConverter() {
        let request = Request<TestCodableObj>(
            requestFactory: URLRequest(url: .demo),
            requestModifiers: [],
            dataModifiers: [],
            responseConverter: JSONConverter<TestCodableObj>()
        )
        TestURLProtocol.setHandler(request: try! request.buildRequest().get()) { req in
            let objectData = try! JSONEncoder().encode(TestCodableObj.success)
            return (objectData, HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
        }
        let promise = expectation(description: #function)
        request.retrieveObject(by: client) { result in
            let object = try? result.get()
            XCTAssertNotNil(object)
            XCTAssertEqual(object?.description, TestCodableObj.success.description)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10.0)
    }
}

private struct Base64Modifier: DataModifiable {
    func modify(_ inputData: Data) -> Result<Data, Error> {
        return .success(inputData.base64EncodedData())
    }
}
