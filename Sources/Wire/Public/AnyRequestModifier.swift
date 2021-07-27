import Foundation

public struct AnyRequestModifier: RequestModifiable {
    public typealias Transform = (URLRequest) -> Result<URLRequest, Error>

    private let transform: Transform

    public init(transform: @escaping Transform) {
        self.transform = transform
    }

    public init<T: RequestModifiable>(_ modifier: T) {
        self.transform = { req in
            modifier.modify(req)
        }
    }

    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        return transform(request)
    }
}
