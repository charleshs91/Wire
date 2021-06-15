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
    ///   - request: An object that addresses the generation of `URLRequest`.
    ///   - dataConverter: An object that transforms `Data` into an `Output` value.
    ///   - completion: A completion handler.
    @discardableResult
    public func retrieveObject<T: RequestBuildable, U: ResponseConvertible>(
        with builder: T,
        responseConverter: U,
        completion: @escaping Completion<U.Output>
    ) -> URLSessionDataTask? {
        return retrieveData(with: builder) { result in
            switch result {
            case .failure(let error):
                // data retrieving failure
                completion(.failure(error))
            case .success(let data):
                // data retrieving success
                switch responseConverter.convert(data: data) {
                case .failure(let error):
                    // data conversion failure
                    completion(.failure(.convertResponseError(error)))
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
        with builder: T,
        completion: @escaping Completion<Data>
    ) -> URLSessionDataTask? {
        switch builder.buildRequest() {
        case .failure(let error):
            completion(.failure(.buildRequestError(error)))
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

    /// Converts the received result of `session.dataTask(with:completionHandler:)` into a value of `Result<Data, BaseError>`.
    func process(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, BaseError> {
        if let error = error {
            return .failure(BaseError.performError(.sessionError(error)))
        }
        guard let response = response else {
            return .failure(BaseError.performError(.noResponse))
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(BaseError.performError(.notHttpResponse(response: response)))
        }
        guard httpResponse.statusCode == 200 else {
            return .failure(BaseError.performError(.httpStatus(code: httpResponse.statusCode, data: data)))
        }
        guard let data = data else {
            // Should not happen.
            return .failure(BaseError.performError(.noData))
        }

        return .success(data)
    }
}

// MARK: - PerformerError
extension DataTaskClient {
    public enum PerformerError: LocalizedError, Equatable {
        /// Error from `URLSession`. The `error` is ignored upon evaluating equality.
        case sessionError(_ error: Error)
        /// No response from server
        case noResponse
        /// The response is not HTTP. The `response` is ignored upon evaluating equality.
        case notHttpResponse(response: URLResponse)
        /// HTTP response with status code other than 200. Only the `code` is taken into equality evaluation.
        case httpStatus(code: Int, data: Data?)
        /// The response (200 OK) does not contain data.
        case noData

        public static func ==(lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.sessionError, .sessionError),
                (.noResponse, .noResponse),
                (.notHttpResponse, .notHttpResponse),
                (.noData, .noData):
                return true
            case (.httpStatus(let codeLeft, _), .httpStatus(let codeRight, _)):
                return codeLeft == codeRight
            default:
                return false
            }
        }

        public var errorDescription: String? {
            switch self {
            case .sessionError(let error):
                return "Session error: \(error.localizedDescription)"
            case .noResponse:
                return "Server did not provide a response."
            case .notHttpResponse:
                return "Response is not HTTP."
            case .httpStatus(let code, _):
                return "HTTP response status code: \(code)"
            case .noData:
                return "Server did not provide data."
            }
        }
    }
}

// MARK: - Combine Supports
#if canImport(Combine)
import Combine

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension DataTaskClient {
    public func objectPublisher<T: RequestBuildable, U: ResponseConvertible>(
        with builder: T,
        responseConverter: U
    ) -> AnyPublisher<U.Output, BaseError> {
        return Future { [unowned self] promise in
            retrieveObject(with: builder, responseConverter: responseConverter, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func dataPublisher<T: RequestBuildable>(
        with builder: T
    ) -> AnyPublisher<Data, BaseError> {
        return Future { [unowned self] promise in
            retrieveData(with: builder, completion: promise)
        }
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - Concurrency Supports
#if swift(>=5.5)
@available(iOS 15.0, tvOS 15.0, watchOS 8.0, OSX 12.0, *)
extension DataTaskClient {
    /// Asynchronously returns an object obtained via `URLSession`.
    /// - Returns: Value of type `Output` defined in `ResponseConvertible`.
    /// - Throws: Error of type `BaseError`.
    public func object<T: RequestBuildable, U: ResponseConvertible>(
        with builder: T,
        objectConverter: U
    ) async throws -> U.Output {
        let data = try await self.data(with: builder)

        switch objectConverter.convert(data: data) {
        case .failure(let error):
            throw BaseError.convertResponseError(error)
        case .success(let output):
            return output
        }
    }

    /// Asynchronously returns a chunk of data obtained via `URLSession`.
    /// - Throws: Error of type `BaseError`.
    public func data<T: RequestBuildable>(
        with builder: T
    ) async throws -> Data {
        switch builder.buildRequest() {
        case .failure(let error):
            throw BaseError.buildRequestError(error)
        case .success(let urlRequest):
            do {
                let (data, response) = try await session.data(for: urlRequest)
                return try process(data: data, response: response, error: nil).get()
            } catch let error as BaseError {
                throw error
            } catch {
                throw BaseError.performError(.sessionError(error))
            }
        }
    }
}
#endif
