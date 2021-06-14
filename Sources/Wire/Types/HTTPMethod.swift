import Foundation

/// Represents a HTTP method.
public struct HTTPMethod {
    public let value: String

    public init(value: String) {
        self.value = value
    }
}

extension HTTPMethod {
    public static let get: HTTPMethod = HTTPMethod(value: "GET")
    public static let head: HTTPMethod = HTTPMethod(value: "HEAD")
    public static let post: HTTPMethod = HTTPMethod(value: "POST")
    public static let put: HTTPMethod = HTTPMethod(value: "PUT")
    public static let delete: HTTPMethod = HTTPMethod(value: "DELETE")
    public static let connect: HTTPMethod = HTTPMethod(value: "CONNECT")
    public static let options: HTTPMethod = HTTPMethod(value: "OPTIONS")
    public static let trace: HTTPMethod = HTTPMethod(value: "TRACE")
    public static let patch: HTTPMethod = HTTPMethod(value: "PATCH")
}

extension HTTPMethod: RequestModifiable {
    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        var req = request
        req.httpMethod = value
        return .success(req)
    }
}
