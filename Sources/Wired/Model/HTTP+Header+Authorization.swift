import Foundation

extension HTTP.Header {
    /// Represents content of the `Authorization` HTTP header field.
    public enum Authorization {
        case basic(_ token: String)
        case bearer(_ token: String)
        case digest(_ token: String)
        case HOBA(_ token: String)
        case mutual(_ token: String)
        case other(String)

        /// The value for the `Authorization` field in a header.
        public var value: String {
            switch self {
            case .basic(let token):
                return "Basic \(token)"
            case .bearer(let token):
                return "Bearer \(token)"
            case .digest(let token):
                return "Digest \(token)"
            case .HOBA(let token):
                return "HOBA \(token)"
            case .mutual(let token):
                return "Mutual \(token)"
            case .other(let value):
                return value
            }
        }
    }
}
