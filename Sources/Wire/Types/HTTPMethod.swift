import Foundation

/// Represents a HTTP method.
public struct HTTPMethod: RequestMethod {
    public let method: String

    public init(value: String) {
        self.method = value
    }
}

extension HTTPMethod {
    public static let get = HTTPMethod(value: "GET")
    public static let head = HTTPMethod(value: "HEAD")
    public static let post = HTTPMethod(value: "POST")
    public static let put = HTTPMethod(value: "PUT")
    public static let delete = HTTPMethod(value: "DELETE")
    public static let connect = HTTPMethod(value: "CONNECT")
    public static let options = HTTPMethod(value: "OPTIONS")
    public static let trace = HTTPMethod(value: "TRACE")
    public static let patch = HTTPMethod(value: "PATCH")
}
