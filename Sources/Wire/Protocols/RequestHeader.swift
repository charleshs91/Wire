import Foundation

public protocol RequestHeader: RequestModifiable {
    var key: String { get }
    var value: String { get }
    var mergesField: Bool { get }
}

extension RequestHeader {
    public func apply(to req: inout URLRequest) {
        mergesField
        ? req.addValue(value, forHTTPHeaderField: key)
        : req.setValue(value, forHTTPHeaderField: key)
    }

    // MARK: RequestModifiable Impl
    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        var req = request
        apply(to: &req)
        return .success(req)
    }
}
