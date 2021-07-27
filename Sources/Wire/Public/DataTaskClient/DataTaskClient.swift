import Foundation

public final class DataTaskClient {

    public typealias Completion<T> = (Result<T, WireBaseError>) -> Void

    public static let shared: DataTaskClient = DataTaskClient(session: .shared)

    public weak var monitor: DataTaskClientMonitoring?

    public let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    /// - Parameters:
    ///   - configuration: A session configuration.
    ///   - delegateQueue: An operation queue for scheduling delegate calls and completion handlers.
    public init(configuration: URLSessionConfiguration, delegateQueue: OperationQueue? = nil) {
        self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: delegateQueue)
    }

    /// Performs a request, transforms the obtained data into an object, and calls a handler on completion.
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

    /// Performs a request and passes the received data via a completion handler.
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
                completion(
                    result.onSuccess { data in self?.didRetrieveData(for: builder, data: data) }
                )
            }

            dataTask.resume()
            didLaunchTask(for: builder)
            return dataTask
        }
    }

    func mappingTaskResponse(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, WireBaseError> {
        if let error = error {
            return .failure(WireBaseError.dataTaskPerformer(.sessionError(error)))
        }
        guard let response = response else {
            return .failure(WireBaseError.dataTaskPerformer(.noResponse))
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(WireBaseError.dataTaskPerformer(.notHttpResponse(response: response)))
        }
        guard httpResponse.statusCode == 200 else {
            return .failure(WireBaseError.dataTaskPerformer(.httpStatus(code: httpResponse.statusCode, data: data)))
        }
        guard let data = data else {
            return .failure(WireBaseError.dataTaskPerformer(.noData))
        }

        return .success(data)
    }

    func getResultOfResponseConversion<T: ResponseConvertible>(_ responseConverter: T, data: Data) -> Result<T.Output, WireBaseError> {
        return responseConverter.convert(data: data).mapError {
            WireBaseError.responseConverter($0)
        }
    }

    private func didRetrieveData<T: RequestBuildable>(for builder: T, data: Data) {
        monitor?.client(self, didReceive: data, requestBuilder: builder)
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
