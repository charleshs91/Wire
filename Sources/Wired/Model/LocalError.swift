import Foundation

public enum LocalError: LocalizedError {
    /// The URL string is invalid.
    case invalidURLString(String)
    /// Error from `URLSession`
    case sessionError(Error)
    /// No response from server
    case noResponse
    /// The response is not HTTP.
    case notHttpResponse(response: URLResponse)
    /// HTTP response with status code other than 200
    case httpStatus(code: Int, data: Data?)
    /// The response (200 OK) does not contain data.
    case noData
    /// Error from `RequestModifiable.modify(_:)`
    case requestModifier(Error)
    /// Error from `DataModifiable.modify(_:)`
    case dataModifierError(Error)
    /// Error from `ResponseConvertible.convert(data:)`
    case responseConverterError(Error)

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
        case .httpStatus(let code, _):
            return "HTTP response status code: \(code)"
        case .noData:
            return "Server did not provide data."
        case .requestModifier(let error),
             .dataModifierError(let error),
             .responseConverterError(let error):
            return error.localizedDescription
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
             (.noData, .noData),
             (.requestModifier, .requestModifier),
             (.dataModifierError, .dataModifierError),
             (.responseConverterError, .responseConverterError):
            return true
        case (.httpStatus(let leftCode, _), .httpStatus(let rightCode, _)):
            return leftCode == rightCode
        default:
            return false
        }
    }
}
