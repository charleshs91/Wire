import Foundation

/// Concrete implementation of `RequestModifiable`.
public struct AnyRequestModifiable: RequestModifiable {
    public typealias Transform = (URLRequest) -> Result<URLRequest, Error>

    private let transform: Transform

    public init(transform: @escaping Transform) {
        self.transform = transform
    }

    public init<T: RequestModifiable>(_ modifier: T) {
        self.transform = { urlRequest in
            return modifier.modify(urlRequest)
        }
    }

    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        return transform(request)
    }
}
