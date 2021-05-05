import Foundation

/// `Request` defines the handling of a networking request, including the generation and modification
/// of `URLRequest` and transformation of the retrieved data into an `Output`.
public struct Request<Output> {
    private let requestBuilder: RequestBuildable
    private let requestModifiers: [RequestModifiable]
    private let dataModifiers: [DataModifiable]
    private let dataConverter: (Data) throws -> Output

    /// Creates a `Request` object.
    /// - Parameters:
    ///   - requestFactory: The `URLRequest` generating object.
    ///   - requestModifiers: A collection of objects that modify the `URLRequest`.
    ///   - dataModifiers: A collection of objects that modify the `Data` from the retrieved response.
    ///   - conversion: The closure which converts the modified data into an `Output`.
    public init(requestBuilder: RequestBuildable,
                requestModifiers: [RequestModifiable] = [],
                dataModifiers: [DataModifiable] = [],
                conversion: @escaping (Data) throws -> Output)
    {
        self.requestBuilder = requestBuilder
        self.requestModifiers = requestModifiers
        self.dataModifiers = dataModifiers
        self.dataConverter = conversion
    }

    /// Creates a `Request` object.
    /// - Parameters:
    ///   - requestFactory: The `URLRequest` generating object.
    ///   - requestModifiers: A collection of objects that modify the `URLRequest`.
    ///   - dataModifiers: A collection of objects that modify the `Data` from the retrieved response.
    ///   - dataConverter: A object that converts the modified data into an `Output`.
    public init<T>(requestFactory: RequestBuildable,
                   requestModifiers: [RequestModifiable] = [],
                   dataModifiers: [DataModifiable] = [],
                   dataConverter: T)
    where T: ResponseConvertible,
          T.Output == Output
    {
        self.requestBuilder = requestFactory
        self.requestModifiers = requestModifiers
        self.dataModifiers = dataModifiers
        self.dataConverter = { data in
            switch dataConverter.convert(data: data) {
            case .failure(let error): throw error
            case .success(let output): return output
            }
        }
    }
}

extension Request where Output == Data {
    /// Creates a `Request` object that does not perform conversion on the received data.
    /// - Parameters:
    ///   - requestFactory: The `URLRequest` generating object.
    ///   - requestModifiers: A collection of objects that modify the `URLRequest`.
    ///   - dataModifiers: A collection of objects that modify the `Data` from the retrieved response.
    public init(requestBuilder: RequestBuildable, requestModifiers: [RequestModifiable] = [], dataModifiers: [DataModifiable] = []) {
        self.init(requestBuilder: requestBuilder, requestModifiers: requestModifiers, dataModifiers: dataModifiers, conversion: { data in data })
    }
}

extension Request: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        switch requestBuilder.buildRequest() {
        case .failure(let error): return .failure(error)
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

extension Request: ResponseConvertible {
    public func convert(data: Data) -> Result<Output, Error> {
        switch modifyResponse(data: data) {
        case .failure(let error): return .failure(error)
        case .success(let data):
            do {
                let output = try dataConverter(data)
                return .success(output)
            } catch {
                return .failure(error)
            }
        }
    }

    private func modifyResponse(data: Data) -> Result<Data, Error> {
        var outputData = data

        for modifier in dataModifiers {
            switch modifier.modify(outputData) {
            case .failure(let error): return .failure(error)
            case .success(let data): outputData = data
            }
        }
        // Return the original data if `responseModifiers` is empty.
        return .success(outputData)
    }
}

extension Request {
    public func retrieveData(client: DataTaskClient = .shared, completion: @escaping (Result<Data, BaseError>) -> Void) {
        let dataConverter = ResponseConverter { data -> Result<Data, Error> in
            return modifyResponse(data: data)
        }
        client.retrieveObject(request: self, dataConverter: dataConverter, completion: completion)
    }

    public func retrieveObject<T: Decodable>(
        client: DataTaskClient = .shared,
        ofType: T.Type = T.self,
        using decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Result<T, BaseError>) -> Void
    ) {
        client.retrieveObject(request: self, dataConverter: JSONConverter<T>(decoder: decoder), completion: completion)
    }
}

#if canImport(Combine)
import Combine

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension Request {
    public func dataPublisher(client: DataTaskClient = .shared) -> AnyPublisher<Data, BaseError> {
        return Future<Data, BaseError> { promise in
            return retrieveData(client: client, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func objectPublisher<T: Decodable>(
        client: DataTaskClient = .shared,
        ofType: T.Type = T.self,
        using decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T, BaseError> {
        return client.objectPublisher(request: self, dataConverter: JSONConverter<T>(decoder: decoder))
    }
}
#endif
