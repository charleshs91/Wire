import Foundation

public protocol RequestMethod: RequestModifiable {
    var method: String { get }
}

// MARK: - RequestModifiable Impl
extension RequestMethod {
    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        var req = request
        req.httpMethod = method
        return .success(req)
    }
}
