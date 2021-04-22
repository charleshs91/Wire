#if canImport(Combine)
import Combine
import Foundation

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension DataTaskClient {
    public func dataPublisher<T>(request: T) -> AnyPublisher<Data, Error>
    where T: RequestBuildable
    {
        return Future<Data, Error> { [unowned self] promise in
            retrieveData(request: request, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func responsePublisher<T, U>(request: T, dataConverter: U) -> AnyPublisher<U.Output, Error>
    where T: RequestBuildable,
          U: ResponseConvertible
    {
        return Future<U.Output, Error> { [unowned self] promise in
            retrieveResponse(request: request, dataConverter: dataConverter, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func responsePublisher<T>(request: T) -> AnyPublisher<T.Output, Error>
    where T: RequestBuildable & ResponseConvertible
    {
        return Future<T.Output, Error> { [unowned self] promise in
            retrieveResponse(request: request, completion: promise)
        }
        .eraseToAnyPublisher()
    }
}
#endif
