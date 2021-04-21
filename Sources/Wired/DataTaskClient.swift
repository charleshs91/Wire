import Foundation

public final class DataTaskClient {
    public typealias Completion<T> = (Result<T, Error>) -> Void

    public static let shared: DataTaskClient = DataTaskClient(configuration: .default)

    private let configuration: URLSessionConfiguration

    private lazy var session: URLSession = URLSession(configuration: configuration)

    public init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
    }

    @discardableResult
    public func retrieveResponse<T>(request: T, completion: @escaping Completion<T.Output>) -> URLSessionDataTask?
    where T: RequestBuildable & ResponseConvertible
    {
        return retrieveResponse(request: request, dataConverter: request, completion: completion)
    }

    @discardableResult
    public func retrieveResponse<T, U>(request: T, dataConverter: U, completion: @escaping Completion<U.Output>) -> URLSessionDataTask?
    where T: RequestBuildable,
          U: ResponseConvertible
    {
        return retrieveData(request: request) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                switch dataConverter.convert(data: data) {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let output):
                    completion(.success(output))
                }
            }
        }
    }

    @discardableResult
    public func retrieveData<T>(request: T, completion: @escaping Completion<Data>) -> URLSessionDataTask?
    where T: RequestBuildable
    {
        switch request.buildRequest() {
        case .failure(let error):
            completion(.failure(error))
            return nil
        case .success(let urlRequest):
            let dataTask = session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    return completion(.failure(LocalError.sessionError(error)))
                }
                guard let response = response else {
                    return completion(.failure(LocalError.noResponse))
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(LocalError.notHttpResponse))
                }
                guard httpResponse.statusCode == 200 else {
                    return completion(.failure(LocalError.httpStatus(code: httpResponse.statusCode)))
                }
                guard let data = data else {
                    return completion(.failure(LocalError.noData))
                }
                return completion(.success(data))
            }

            dataTask.resume()
            return dataTask
        }
    }
}
