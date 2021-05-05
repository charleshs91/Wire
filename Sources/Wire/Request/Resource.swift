#if canImport(Combine)
import Combine
#endif
import Foundation

public struct Resource {
    /// URL of a URLRequest.
    public let url: URL

    /// HTTP method of a URLRequest
    public let method: HTTPMethod

    /// Headers of a URLRequest
    public let headers: [HTTPHeader]

    /// Body of a URLRequest
    public let body: Data?

    /// Creates a resource with a path represented by a string.
    /// - Parameters:
    ///   - urlString: The URL string of the resource.
    ///   - method: HTTP method for the resource. `.get` by default
    ///   - headers: Header fields for the resource. Empty by default.
    ///   - body: Body of the URLRequest. `nil` by default.
    public init?(urlString: String, method: HTTPMethod = .get, headers: [HTTPHeader] = [], body: Data? = nil) {
        guard let url = URL(string: urlString) else { return nil }
        self = Resource(url: url, method: method, headers: headers, body: body)
    }

    /// Creates a resource that represents a `URLRequest`.
    /// - Parameters:
    ///   - url: `URL` of the resource.
    ///   - method: HTTP method for the resource. `.get` by default
    ///   - headers: Header fields for the resource. Empty by default.
    ///   - body: Body of the URLRequest. `nil` by default.
    public init(url: URL, method: HTTPMethod = .get, headers: [HTTPHeader] = [], body: Data? = nil) {
        self.url = url
        self.headers = headers
        self.method = method
        self.body = body
    }
}

// MARK: - RequestBuildable conformance

extension Resource: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.value
        headers.forEach { $0.modify(request: &urlRequest) }
        urlRequest.httpBody = body
        return .success(urlRequest)
    }
}

// MARK: - Convenient methods

extension Resource {
    public func retrieveData(
        by client: DataTaskClient = .shared,
        completion: @escaping (Result<Data, BaseError>) -> Void
    ) {
        client.retrieveData(request: self, completion: completion)
    }

    public func retrieveObject<T: Decodable>(
        by client: DataTaskClient = .shared,
        asType: T.Type = T.self,
        using decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Result<T, BaseError>) -> Void
    ) {
        client.retrieveObject(request: self, dataConverter: JSONConverter<T>(decoder: decoder), completion: completion)
    }
}

// MARK: - Supporting Combine framework

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension Resource {
    public func dataPublisher(
        client: DataTaskClient = .shared
    ) -> AnyPublisher<Data, BaseError> {
        return client.dataPublisher(request: self)
    }

    public func objectPublisher<T: Decodable>(
        client: DataTaskClient = .shared,
        asType: T.Type = T.self,
        using decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T, BaseError> {
        return client.objectPublisher(request: self, dataConverter: JSONConverter<T>(decoder: decoder))
    }
}

// MARK: - Debugging

extension Resource: CustomDebugStringConvertible {
    public var debugDescription: String {
        return """
        URLString = \(url.absoluteString)
        Method = \(method.value)
        Headers = \(headers.map { "\($0.key): \($0.value)" }.sorted().joined(separator: ", "))
        body = \(body?.utf8String(or: "Body is not UTF8 encoded") ?? "Empty body")
        """
    }
}
