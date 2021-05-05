import Foundation

public struct Resource: RequestBuildable {
    /// URL of a URLRequest.
    public let url: URL

    /// Headers of a URLRequest
    public let headers: [HTTPHeader]

    /// HTTP method of a URLRequest
    public let method: HTTPMethod

    /// Body of a URLRequest
    public let body: Data?

    /// Creates a resource with a path represented by a string.
    /// - Parameters:
    ///   - urlString: The URL string of the resource.
    ///   - headers: Header fields for the resource. Empty by default.
    ///   - method: HTTP method for the resource. `.get` by default
    ///   - body: Body of the URLRequest. `nil` by default.
    public init?(urlString: String, headers: [HTTPHeader] = [], method: HTTPMethod = .get, body: Data? = nil) {
        guard let url = URL(string: urlString) else { return nil }
        self = Resource(url: url, headers: headers, method: method, body: body)
    }

    /// Creates a resource that represents a `URLRequest`.
    /// - Parameters:
    ///   - url: `URL` of the resource.
    ///   - headers: Header fields for the resource. Empty by default.
    ///   - method: HTTP method for the resource. `.get` by default
    ///   - body: Body of the URLRequest. `nil` by default.
    public init(url: URL, headers: [HTTPHeader] = [], method: HTTPMethod = .get, body: Data? = nil) {
        self.url = url
        self.headers = headers
        self.method = method
        self.body = body
    }

    public func buildRequest() -> Result<URLRequest, Error> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.value
        headers.forEach { $0.modify(request: &urlRequest) }
        urlRequest.httpBody = body
        return .success(urlRequest)
    }
}

// MARK: - Methods incorporating DataTaskClient

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

#if canImport(Combine)
import Combine

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
#endif
