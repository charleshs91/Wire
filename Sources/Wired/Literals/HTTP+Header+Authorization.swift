import Foundation

extension HTTP.Header {
    /// Represents content of the `Authorization` HTTP header field.
    public enum Authorization {
        case bearer(_ token: String)
        case other(String)

        /// The value for the `Authorization` field in a header.
        public var value: String {
            switch self {
            case .bearer(let token):
                return "Bearer \(token)"
            case .other(let value):
                return value
            }
        }
    }
}
