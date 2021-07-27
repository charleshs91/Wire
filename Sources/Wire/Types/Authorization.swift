import Foundation

/// Represents the `Authorization` HTTP header field.
public enum Authorization: RequestHeader {
    case bearer(String)
    case customized(String)

    public var mergesField: Bool {
        return false
    }

    public var key: String {
        return "Authorization"
    }

    /// The value for the `Authorization` field in a header.
    public var value: String {
        switch self {
        case .bearer(let token):
            return "Bearer \(token)"
        case .customized(let value):
            return value
        }
    }
}
