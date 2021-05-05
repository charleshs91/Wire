#if canImport(Combine)
import Combine
import Foundation

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension DataTaskClient {
    public func objectPublisher<T: RequestBuildable, U: ResponseConvertible>(request: T, dataConverter: U) -> AnyPublisher<U.Output, BaseError> {
        return Future { [weak self] promise in
            self?.retrieveObject(request: request, dataConverter: dataConverter, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func objectPublisher<T: RequestBuildable & ResponseConvertible>(request: T) -> AnyPublisher<T.Output, BaseError> {
        return Future { [weak self] promise in
            self?.retrieveObject(request: request, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func dataPublisher<T: RequestBuildable>(request: T) -> AnyPublisher<Data, BaseError> {
        return Future { [weak self] promise in
            self?.retrieveData(request: request, completion: promise)
        }
        .eraseToAnyPublisher()
    }
}
#endif
