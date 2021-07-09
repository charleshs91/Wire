import Foundation

public final class DataTaskClient {
    public typealias Completion<T> = (Result<T, BaseError>) -> Void

    /// The shared object of `DataTaskClient` that uses `URLSession.shared` as its session.
    public static let shared: DataTaskClient = DataTaskClient()

    public weak var monitor: DataTaskClientMonitoring?

    let session: URLSession

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
    public func retrieveObject<T, U>(with builder: T, responseConverter: U, completion: @escaping Completion<U.Output>) -> URLSessionDataTask?
    where T: RequestBuildable, U: ResponseConvertible {
        return retrieveData(with: builder) { [weak self] result in
            guard let self = self else { return }
            completion(result.flatMap { data in
                self.getResultOfResponseConversion(responseConverter, data: data)
            })
        }
    }

    /// Retrieves the contents of a request and calls a handler upon completion.
    /// - Parameters:
    ///   - request: An object that addresses the generation of `URLRequest`.
    ///   - completion: A completion handler.
    @discardableResult
    public func retrieveData<T>(with builder: T, completion: @escaping Completion<Data>) -> URLSessionDataTask?
    where T: RequestBuildable {
        switch builder.buildRequest() {
        case .failure(let error):
            completion(.failure(.requestBuilder(error)))
            return nil
        case .success(let urlRequest):
            let dataTask = getDataProvidingTask(for: urlRequest) { [weak self] result in
                completion(result.onSuccess { data in
                    self?.didRetrieveData(for: builder, data: data)
                })
            }
            dataTask.resume()
            didLaunchTask(for: builder)
            return dataTask
        }
    }

    func mappingTaskResponse(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, BaseError> {
        if let error = error {
            return .failure(BaseError.dataTaskPerformer(.sessionError(error)))
        }
        guard let response = response else {
            return .failure(BaseError.dataTaskPerformer(.noResponse))
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(BaseError.dataTaskPerformer(.notHttpResponse(response: response)))
        }
        guard httpResponse.statusCode == 200 else {
            return .failure(BaseError.dataTaskPerformer(.httpStatus(code: httpResponse.statusCode, data: data)))
        }
        guard let data = data else {
            return .failure(BaseError.dataTaskPerformer(.noData))
        }
        
        return .success(data)
    }

    func getResultOfResponseConversion<T: ResponseConvertible>(_ responseConverter: T, data: Data) -> Result<T.Output, BaseError> {
        return responseConverter.convert(data: data).mapError {
            BaseError.responseConverter($0)
        }
    }

    private func didRetrieveData<T: RequestBuildable>(for builder: T, data: Data) {
        monitor?.client(self, didSucceedWith: data, requestBuilder: builder)
    }

    private func didLaunchTask<T: RequestBuildable>(for builder: T) {
        monitor?.client(self, didExecute: builder)
    }

    private func getDataProvidingTask(for request: URLRequest, completion: @escaping Completion<Data>) -> URLSessionDataTask {
        return session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            completion(self.mappingTaskResponse(data: data, response: response, error: error))
        }
    }
}
