import Foundation

public final class DataTaskClient {
    public typealias Completion<T> = (Result<T, BaseError>) -> Void

    /// The shared object of `DataTaskClient` that uses `URLSession.shared` as its session.
    public static let shared: DataTaskClient = DataTaskClient()

    let session: URLSession

    /// Creates a data task client via a session.
    /// - Parameter session: A session used by the client. If not provided, `URLSession.shared` is used by default.
    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Creates a data task client via a sesson configuration.
    /// - Parameters:
    ///   - configuration: A session configuration.
    ///   - delegateQueue: An operation queue for scheduling delegate calls and completion handlers.
    public init(configuration: URLSessionConfiguration, delegateQueue: OperationQueue? = nil) {
        self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: delegateQueue)
    }

    /// Retrieves the contents of a request, transforms the obtained data into a specific object, and calls a handler upon completion.
    /// - Parameters:
    ///   - request: An object that addresses both the generation of `URLRequest` and conversion from `Data` into an `Output` value.
    ///   - completion: A completion handler.
    @discardableResult
    public func retrieveObject<T: RequestBuildable & ResponseConvertible>(
        with requestAndResponseProvider: T,
        completion: @escaping Completion<T.Output>
    ) -> URLSessionDataTask? {
        return retrieveObject(with: requestAndResponseProvider, responseConverter: requestAndResponseProvider, completion: completion)
    }

    /// Retrieves the contents of a request, transforms the obtained data into a specific object, and calls a handler upon completion.
    /// - Parameters:
    ///   - request: An object that addresses the generation of `URLRequest`.
    ///   - dataConverter: An object that transforms `Data` into an `Output` value.
    ///   - completion: A completion handler.
    @discardableResult
    public func retrieveObject<T: RequestBuildable, U: ResponseConvertible>(
        with requestFactory: T,
        responseConverter: U,
        completion: @escaping Completion<U.Output>
    ) -> URLSessionDataTask? {
        return retrieveData(with: requestFactory) { result in
            switch result {
            case .failure(let error):
                // data retrieving failure
                completion(.failure(error))
            case .success(let data):
                // data retrieving success
                switch responseConverter.convert(data: data) {
                case .failure(let error):
                    // data conversion failure
                    completion(.failure(.responseConversionError(error)))
                case .success(let output):
                    // data conversion success
                    completion(.success(output))
                }
            }
        }
    }

    /// Retrieves the contents of a request and calls a handler upon completion.
    /// - Parameters:
    ///   - request: An object that addresses the generation of `URLRequest`.
    ///   - completion: A completion handler.
    @discardableResult
    public func retrieveData<T: RequestBuildable>(
        with requestFactory: T,
        completion: @escaping Completion<Data>
    ) -> URLSessionDataTask? {
        switch requestFactory.buildRequest() {
        case .failure(let error):
            completion(.failure(.requestBuildingError(error)))
            return nil
        case .success(let urlRequest):
            let dataTask = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                guard let self = self else {
                    return assertionFailure("Client being released before the completion cllback of its data task.")
                }
                completion(self.process(data: data, response: response, error: error))
            }
            dataTask.resume()

            return dataTask
        }
    }
}

// MARK: - Internal
extension DataTaskClient {
    /// Converts the received result of `session.dataTask(with:completionHandler:)` into a value of `Result<Data, BaseError>`.
    func process(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, BaseError> {
        if let error = error {
            return .failure(BaseError.sessionError(error))
        }
        guard let response = response else {
            return .failure(BaseError.noResponse)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(BaseError.notHttpResponse(response: response))
        }
        guard httpResponse.statusCode == 200 else {
            return .failure(BaseError.httpStatus(code: httpResponse.statusCode, data: data))
        }
        guard let data = data else {
            // Should not happen.
            return .failure(BaseError.noData)
        }

        return .success(data)
    }
}
