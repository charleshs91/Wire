import Foundation

/// Represents the `Content-Type` HTTP header field.
public enum ContentType: RequestHeader {
    case dataForm
    case urlEncodedForm
    case json
    case plainText
    case customized(String)

    public var mergesField: Bool {
        return false
    }

    public var key: String {
        return "Content-Type"
    }

    /// The value for the `Content-Type` field in a header.
    public var value: String {
        switch self {
        case .dataForm:
            return "multipart/form-data"
        case .urlEncodedForm:
            return "application/x-www-form-urlencoded;charset=utf-8"
        case .json:
            return "application/json;charset=utf-8"
        case .plainText:
            return "text/plain;charset=utf-8"
        case .customized(let value):
            return value
        }
    }
}
