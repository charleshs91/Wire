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
    ///   - urlString: A string representing the URI to a fetchable resource.
    ///   - method: The ``HTTPMethod`` for the resource. (`.get` by default)
    ///   - headers: A list of ``HTTPHeader`` representing header fields for the resource. (Empty by default)
    ///   - body: Body of the URLRequest. (`nil` by default)
    public init?(urlString: String, method: HTTPMethod = .get, headers: [HTTPHeader] = [], body: Data? = nil) {
        guard let url = URL(string: urlString) else {
            return nil
        }

        self = Resource(url: url, method: method, headers: headers, body: body)
    }

    /// Creates a resource that represents a `URLRequest`.
    /// - Parameters:
    ///   - url: A `URL` value indicating a fetchable resource.
    ///   - method: The ``HTTPMethod`` for the resource. (`.get` by default)
    ///   - headers: A list of ``HTTPHeader`` representing header fields for the resource. (Empty by default)
    ///   - body: Body of the URLRequest. (`nil` by default)
    public init(url: URL, method: HTTPMethod = .get, headers: [HTTPHeader] = [], body: Data? = nil) {
        self.url = url
        self.headers = headers
        self.method = method
        self.body = body
    }
}

// MARK: - RequestBuildable Conformance
extension Resource: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.value
        headers.forEach { item in
            item.modify(request: &urlRequest)
        }
        urlRequest.httpBody = body
        return .success(urlRequest)
    }
}

// MARK: - Methods with Closure
extension Resource {
    public func retrieveData(
        using client: DataTaskClient = .shared,
        completion: @escaping (Result<Data, BaseError>) -> Void
    ) {
        client.retrieveData(requestFactory: self, completion: completion)
    }

    public func retrieveObject<T: Decodable>(
        using client: DataTaskClient = .shared,
        asType: T.Type = T.self,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Result<T, BaseError>) -> Void
    ) {
        client.retrieveObject(requestFactory: self, responseConverter: JSONConverter<T>(decoder: decoder), completion: completion)
    }
}

// MARK: - Combine Supports
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension Resource {
    public func dataPublisher(
        using client: DataTaskClient = .shared
    ) -> AnyPublisher<Data, BaseError> {
        return client.dataPublisher(with: self)
    }

    public func objectPublisher<T: Decodable>(
        using client: DataTaskClient = .shared,
        asType: T.Type = T.self,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T, BaseError> {
        return client.objectPublisher(with: self, responseConverter: JSONConverter<T>(decoder: decoder))
    }
}

// MARK: - Concurrency Supports
@available(iOS 15.0, tvOS 15.0, watchOS 8.0, OSX 12.0, *)
extension Resource {
    public func data(
        using client: DataTaskClient = .shared
    ) async throws -> Data {
        return try await client.data(with: self)
    }

    public func object<T: Decodable>(
        using client: DataTaskClient = .shared,
        asType: T.Type = T.self,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        return try await client.object(with: self, objectConverter: JSONConverter<T>(decoder: decoder))
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
