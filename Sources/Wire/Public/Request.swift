#if canImport(Combine)
import Combine
#endif
import Foundation

/// `Request` defines the handling of a networking request, including the generation and modification
/// of `URLRequest` and transformation of the retrieved data into an `Output`.
public struct Request<Output> {
    private let requestFactory: RequestBuildable
    private let requestModifiers: [RequestModifiable]
    private let dataModifiers: [DataModifiable]
    private let responseConversion: (Data) -> Result<Output, Error>

    /// Creates a `Request` object.
    /// - Parameters:
    ///   - requestFactory: The `URLRequest` generating object.
    ///   - requestModifiers: A collection of objects that modify the `URLRequest`.
    ///   - dataModifiers: A collection of objects that modify the `Data` from the retrieved response.
    ///   - conversion: The closure which converts the modified data into an `Output`.
    public init(
        requestFactory: RequestBuildable,
        requestModifiers: [RequestModifiable] = [],
        dataModifiers: [DataModifiable] = [],
        conversion: @escaping (Data) throws -> Output
    ) {
        self.requestFactory = requestFactory
        self.requestModifiers = requestModifiers
        self.dataModifiers = dataModifiers
        self.responseConversion = { data in
            return .mapThrowable {
                return try conversion(data)
            }
        }
    }

    /// Creates a `Request` object.
    /// - Parameters:
    ///   - requestFactory: The `URLRequest` generating object.
    ///   - requestModifiers: A collection of objects that modify the `URLRequest`.
    ///   - dataModifiers: A collection of objects that modify the `Data` from the retrieved response.
    ///   - responseConverter: A object that converts the modified data into an `Output`.
    public init<T: ResponseConvertible>(
        requestFactory: RequestBuildable,
        requestModifiers: [RequestModifiable] = [],
        dataModifiers: [DataModifiable] = [],
        responseConverter: T
    ) where T.Output == Output {
        self.requestFactory = requestFactory
        self.requestModifiers = requestModifiers
        self.dataModifiers = dataModifiers
        self.responseConversion = { data in
            return responseConverter.convert(data: data)
        }
    }

    /// Creates a `Request` object that does not perform conversion on the processed data.
    /// - Parameters:
    ///   - requestFactory: The `URLRequest` generating object.
    ///   - requestModifiers: A collection of objects that modify the `URLRequest`.
    ///   - dataModifiers: A collection of objects that modify the `Data` from the retrieved response.
    public init(
        requestFactory: RequestBuildable,
        requestModifiers: [RequestModifiable] = [],
        dataModifiers: [DataModifiable] = []
    ) where Output == Data {
        self.init(requestFactory: requestFactory, requestModifiers: requestModifiers, dataModifiers: dataModifiers, conversion: { data in data })
    }
}

// MARK: - RequestBuildable Conformance
extension Request: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        switch requestFactory.buildRequest() {
        case .failure(let error):
            return .failure(error)
        case .success(let request):
            var buffer = request

            for modifier in requestModifiers {
                switch modifier.modify(buffer) {
                case .failure(let error):
                    // Early return
                    return .failure(error)
                case .success(let req):
                    buffer = req
                }
            }
            // Return the original URLRequest if `requestModifiers` is empty.
            return .success(buffer)
        }
    }
}

// MARK: - ResponseConvertible Conformance
extension Request: ResponseConvertible {
    public func convert(data: Data) -> Result<Output, Error> {
        switch modify(data: data) {
        case .failure(let error):
            return .failure(error)
        case .success(let data):
            return responseConversion(data)
        }
    }

    private func modify(data: Data) -> Result<Data, Error> {
        var buffer = data

        for modifier in dataModifiers {
            switch modifier.modify(buffer) {
            case .failure(let error):
                // Early return
                return .failure(error)
            case .success(let data):
                buffer = data
            }
        }
        // Return the original data if `responseModifiers` is empty.
        return .success(buffer)
    }
}

// MARK: - Methods with Closure
extension Request {
    public func retrieveData(
        using client: DataTaskClient = .shared,
        completion: @escaping (Result<Data, BaseError>) -> Void
    ) {
        let dataConverter = AnyResponseConvertible { data in
            return modify(data: data)
        }
        client.retrieveObject(with: self, responseConverter: dataConverter, completion: completion)
    }

    public func retrieveObject(
        using client: DataTaskClient = .shared,
        completion: @escaping (Result<Output, BaseError>) -> Void
    ) {
        client.retrieveObject(with: self, completion: completion)
    }
}

// MARK: - Combine Supports
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension Request {
    public func dataPublisher(using client: DataTaskClient = .shared) -> AnyPublisher<Data, BaseError> {
        return client.objectPublisher(with: self, responseConverter: AnyResponseConvertible { data in
            return modify(data: data)
        })
    }

    public func objectPublisher(using client: DataTaskClient = .shared) -> AnyPublisher<Output, BaseError> {
        return client.objectPublisher(with: self)
    }
}

#if swift(>=5.5)
// MARK: - Concurrency Supports
@available(iOS 15.0, tvOS 15.0, watchOS 8.0, OSX 12.0, *)
extension Request {
    public func data(using client: DataTaskClient = .shared) async throws -> Data {
        try await client.data(with: self)
    }

    public func object(using client: DataTaskClient = .shared) async throws -> Output {
        try await client.object(with: self, objectConverter: AnyResponseConvertible(transform: responseConversion))
    }
}
#endif
