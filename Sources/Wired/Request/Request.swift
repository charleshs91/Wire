import Foundation

/// `Request` defines the handling of a networking request, including the generation and modification
/// of `URLRequest` and transformation of the retrieved data into an `Output`.
public struct Request<Output> {
    private let requestFactory: RequestBuildable
    private let requestModifiers: [RequestModifiable]
    private let dataModifiers: [DataModifiable]
    private let dataConverter: (Data) throws -> Output

    /// Creates a `Request` object.
    /// - Parameters:
    ///   - requestFactory: The `URLRequest` generating object.
    ///   - requestModifiers: A collection of objects that modify the `URLRequest`.
    ///   - dataModifiers: A collection of objects that modify the `Data` from the retrieved response.
    ///   - dataConverter: The closure which converts the modified data into an `Output`.
    public init(requestFactory: RequestBuildable,
                requestModifiers: [RequestModifiable] = [],
                dataModifiers: [DataModifiable] = [],
                dataConverter: @escaping (Data) throws -> Output)
    {
        self.requestFactory = requestFactory
        self.requestModifiers = requestModifiers
        self.dataModifiers = dataModifiers
        self.dataConverter = dataConverter
    }
}

extension Request: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        switch requestFactory.buildRequest() {
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
    public func getData(completion: @escaping (Result<Data, Error>) -> Void) {
        let dataConverter = ResponseConverter { data -> Result<Data, Error> in
            return modifyResponse(data: data)
        }
        DataTaskClient.shared.retrieveResponse(request: self, dataConverter: dataConverter, completion: completion)
    }

    public func getJSON<T: Decodable>(ofType: T.Type,
                                      using decoder: JSONDecoder = JSONDecoder(),
                                      completion: @escaping (Result<T, Error>) -> Void)
    {
        DataTaskClient.shared.retrieveResponse(request: self,
                                               dataConverter: JSONConverter<T>(decoder: decoder),
                                               completion: completion)
    }
}
