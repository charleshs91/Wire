import Foundation

public enum LocalError: LocalizedError {
    /// The URL string is invalid.
    case invalidURLString(String)
    /// Error from `URLSession`.
    case sessionError(Error)
    /// No response from server
    case noResponse
    /// The response is not HTTP
    case notHttpResponse
    /// HTTP response with status code other than 200
    case httpStatus(code: Int)
    /// The response does not contain data
    case noData

    public var errorDescription: String? {
        switch self {
        case .invalidURLString(let urlString):
            return "`\(urlString)` is not a valid URL."
        case .sessionError(let error):
            return "Session error: \(error)."
        case .noResponse:
            return "Server did not provide a response."
        case .notHttpResponse:
            return "Response is not HTTP."
        case .httpStatus(let code):
            return "HTTP response status code: \(code)"
        case .noData:
            return "Server did not provide data."
        }
    }
}

extension LocalError: Equatable {
    public static func ==(lhs: LocalError, rhs: LocalError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURLString(let leftString), .invalidURLString(let rightString)):
            return leftString == rightString
        case (.sessionError, .sessionError),
             (.noResponse, .noResponse),
             (notHttpResponse, .notHttpResponse),
             (.noData, .noData):
            return true
        case (.httpStatus(let leftCode), .httpStatus(let rightCode)):
            return leftCode == rightCode
        default:
            return false
        }
    }
}
