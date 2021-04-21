import Foundation

public protocol RequestModifier {
    func modify(_ request: URLRequest) -> Result<URLRequest, Error>
}

public struct AnyRequestModifier: RequestModifier {
    private let _modify: (URLRequest) -> Result<URLRequest, Error>

    public init<T: RequestModifier>(_ modifier: T) {
        _modify = { urlRequest in
            return modifier.modify(urlRequest)
        }
    }

    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        return _modify(request)
    }
}
