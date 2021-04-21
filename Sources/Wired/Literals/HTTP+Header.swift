import Foundation

extension HTTP {
    /// Represents a HTTP header field.
    public enum Header {
        case authorization(Authorization)
        case contentType(ContentType)
        case userAgent(String)
        case other(key: String, value: String)

        /// The key of the header field.
        public var key: String {
            switch self {
            case .authorization: return "Authorization"
            case .contentType: return "Content-Type"
            case .userAgent: return "User-Agent"
            case .other(let key, _): return key
            }
        }

        /// The value of the header field.
        public var value: String {
            switch self {
            case .authorization(let authroization):
                return authroization.value
            case .userAgent(let value):
                return value
            case .contentType(let contentType):
                return contentType.value
            case .other(_, let value):
                return value
            }
        }

        /// Modifies a URLRequest to apply this header.
        public func modify(request: inout URLRequest) {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
