import Foundation

extension HTTP.Header {
    /// Represents content of the `Content-Type` HTTP header field.
    public enum ContentType {
        case formData
        case urlEncodedForm
        case json
        case plain
        case other(String)

        /// The value for the `Content-Type` field in a header.
        public var value: String {
            switch self {
            case .formData: return "multipart/form-data"
            case .urlEncodedForm: return "application/x-www-form-urlencoded;charset=utf-8"
            case .json: return "application/json;charset=utf-8"
            case .plain: return "text/plain;charset=utf-8"
            case .other(let value): return value
            }
        }
    }
}
