#if canImport(Combine)
import Combine
import Foundation

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension DataTaskClient {
    public func dataPublisher<T>(request: T) -> AnyPublisher<Data, LocalError>
    where T: RequestBuildable
    {
        return Future { [weak self] promise in
            self?.retrieveData(request: request, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func objectPublisher<T, U>(request: T, dataConverter: U) -> AnyPublisher<U.Output, LocalError>
    where T: RequestBuildable,
          U: ResponseConvertible
    {
        return Future { [weak self] promise in
            self?.retrieveObject(request: request, dataConverter: dataConverter, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func objectPublisher<T>(request: T) -> AnyPublisher<T.Output, LocalError>
    where T: RequestBuildable & ResponseConvertible
    {
        return Future { [weak self] promise in
            self?.retrieveObject(request: request, completion: promise)
        }
        .eraseToAnyPublisher()
    }
}
#endif
