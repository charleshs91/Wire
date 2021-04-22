import Foundation

public struct RequestModifier: RequestModifiable {
    public typealias Modifier = (URLRequest) -> Result<URLRequest, Error>

    private let modifier: Modifier

    public init(closure: @escaping Modifier) {
        modifier = closure
    }

    public init<T: RequestModifiable>(_ modifier: T) {
        self.modifier = { urlRequest in
            return modifier.modify(urlRequest)
        }
    }

    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        return modifier(request)
    }
}
