#if canImport(Combine)
import Combine
import Foundation

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension DataTaskClient {
    public func objectPublisher<T: RequestBuildable, U: ResponseConvertible>(
        with requestFactory: T,
        responseConverter: U
    ) -> AnyPublisher<U.Output, BaseError> {
        return Future { [weak self] promise in
            self?.retrieveObject(requestFactory: requestFactory, responseConverter: responseConverter, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func objectPublisher<T: RequestBuildable & ResponseConvertible>(
        with requestAndResponseProvider: T
    ) -> AnyPublisher<T.Output, BaseError> {
        return Future { [weak self] promise in
            self?.retrieveObject(with: requestAndResponseProvider, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func dataPublisher<T: RequestBuildable>(
        with requestFactory: T
    ) -> AnyPublisher<Data, BaseError> {
        return Future { [weak self] promise in
            self?.retrieveData(requestFactory: requestFactory, completion: promise)
        }
        .eraseToAnyPublisher()
    }
}
#endif
