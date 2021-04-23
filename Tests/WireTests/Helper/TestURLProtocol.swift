import Foundation
import XCTest

typealias RequestHandler = (URLRequest) -> (data: Data?, response: URLResponse?, error: Error?)

private var requestHandlers: [URLRequest: RequestHandler] = [:]

final class TestURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    static func setHandler(request: URLRequest, _ handler: @escaping RequestHandler) {
        requestHandlers[request] = handler
    }

    static func clearHandlers() {
        requestHandlers.removeAll()
    }

    override func startLoading() {
        defer { client?.urlProtocolDidFinishLoading(self) }
        
        guard let handler = requestHandlers[request] else {
            preconditionFailure("Handler for \(request) is not provided.")
        }

        let response = handler(request)

        if let error = response.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else if let urlResponse = response.response {
            client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
            response.data.map {
                client?.urlProtocol(self, didLoad: $0)
            }
        }
    }

    override func stopLoading() {}
}
