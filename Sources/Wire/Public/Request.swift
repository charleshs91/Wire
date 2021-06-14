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
            do {
                return .success(try conversion(data))
            } catch {
                return .failure(error)
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
        case .success(let urlRequest):
            var outputRequest = urlRequest

            for modifier in requestModifiers {
                switch modifier.modify(outputRequest) {
                case .failure(let error): return .failure(error)
                case .success(let req): outputRequest = req
                }
            }
            // Return the original URLRequest if `requestModifiers` is empty.
            return .success(outputRequest)
        }
    }
}

// MARK: - ResponseConvertible Conformance
extension Request: ResponseConvertible {
    public func convert(data: Data) -> Result<Output, Error> {
        switch modifyResponse(data: data) {
        case .failure(let error):
            return .failure(error)
        case .success(let data):
            return responseConversion(data)
        }
    }

    private func modifyResponse(data: Data) -> Result<Data, Error> {
        var outputData = data

        for modifier in dataModifiers {
            switch modifier.modify(outputData) {
            case .failure(let error):
                return .failure(error)
            case .success(let data):
                outputData = data
            }
        }
        // Return the original data if `responseModifiers` is empty.
        return .success(outputData)
    }
}

// MARK: - Methods with Closure
extension Request {
    public func retrieveData(
        by client: DataTaskClient = .shared,
        completion: @escaping (Result<Data, BaseError>) -> Void
    ) {
        let dataConverter = AnyResponseConvertible { data -> Result<Data, Error> in
            return modifyResponse(data: data)
        }
        client.retrieveObject(requestFactory: self, responseConverter: dataConverter, completion: completion)
    }

    public func retrieveObject(
        by client: DataTaskClient = .shared,
        completion: @escaping (Result<Output, BaseError>) -> Void
    ) {
        let dataConverter = AnyResponseConvertible { data -> Result<Output, Error> in
            return convert(data: data)
        }
        client.retrieveObject(requestFactory: self, responseConverter: dataConverter, completion: completion)
    }
}

// MARK: - Combine Supports
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension Request {
    public func dataPublisher(
        client: DataTaskClient = .shared
    ) -> AnyPublisher<Data, BaseError> {
        return Future<Data, BaseError> { promise in
            return retrieveData(by: client, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func objectPublisher(
        client: DataTaskClient = .shared,
        using decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<Output, BaseError> {
        return Future<Output, BaseError> { promise in
            return retrieveObject(by: client, completion: promise)
        }
        .eraseToAnyPublisher()
    }
}

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
