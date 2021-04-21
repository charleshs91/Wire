import Foundation

enum LocalError: LocalizedError {
    case invalidURLString(String)
    // client
    case sessionError(Error)
    case noResponse
    case notHttpResponse
    case httpStatus(code: Int)
    case noData

    var errorDescription: String? {
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
    static func ==(lhs: LocalError, rhs: LocalError) -> Bool {
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
