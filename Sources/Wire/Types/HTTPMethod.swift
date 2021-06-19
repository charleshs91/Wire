import Foundation

/// Represents a HTTP method.
public struct HTTPMethod: RequestMethod {
    public let method: String

    public init(value: String) {
        self.method = value
    }
}

extension HTTPMethod {
    public static let get: HTTPMethod = .init(value: "GET")
    public static let head: HTTPMethod = .init(value: "HEAD")
    public static let post: HTTPMethod = .init(value: "POST")
    public static let put: HTTPMethod = .init(value: "PUT")
    public static let delete: HTTPMethod = .init(value: "DELETE")
    public static let connect: HTTPMethod = .init(value: "CONNECT")
    public static let options: HTTPMethod = .init(value: "OPTIONS")
    public static let trace: HTTPMethod = .init(value: "TRACE")
    public static let patch: HTTPMethod = .init(value: "PATCH")
}
