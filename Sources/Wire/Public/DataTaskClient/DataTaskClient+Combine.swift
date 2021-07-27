#if canImport(Combine)
import Combine
import Foundation

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, OSX 10.15, *)
extension DataTaskClient {
    public func objectPublisher<T, U>(with builder: T, responseConverter: U) -> AnyPublisher<U.Output, WireBaseError>
    where T: RequestBuildable, U: ResponseConvertible {
        Future { [unowned self] promise in
            retrieveObject(with: builder, responseConverter: responseConverter, completion: promise)
        }
        .eraseToAnyPublisher()
    }

    public func dataPublisher<T>(with builder: T) -> AnyPublisher<Data, WireBaseError>
    where T: RequestBuildable {
        Future { [unowned self] promise in
            retrieveData(with: builder, completion: promise)
        }
        .eraseToAnyPublisher()
    }
}
#endif
