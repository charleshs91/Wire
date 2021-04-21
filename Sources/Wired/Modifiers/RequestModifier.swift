import Foundation

public protocol RequestModifier {
    func modify(_ request: URLRequest) -> Result<URLRequest, Error>
}

public struct AnyRequestModifier: RequestModifier {
    public typealias Modifier = (URLRequest) -> Result<URLRequest, Error>

    private let modifier: Modifier

    public init(closure: @escaping Modifier) {
        modifier = closure
    }

    public init<T: RequestModifier>(_ modifier: T) {
        self.modifier = { urlRequest in
            return modifier.modify(urlRequest)
        }
    }

    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        return modifier(request)
    }
}
