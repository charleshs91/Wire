import Foundation

public enum LocalError: LocalizedError {

    /// The URL string is invalid. The associated value represents the URL string,
    /// which is compared upon evaluating equality.
    case invalidURLString(String)

    /// Error from `URLSession`. The `error` is ignored upon evaluating equality.
    case sessionError(_ error: Error)

    /// No response from server
    case noResponse

    /// The response is not HTTP. The `response` is taken into equality evaluation.
    case notHttpResponse(response: URLResponse)

    /// HTTP response with status code other than 200. Only the `code` is taken into equality evaluation.
    case httpStatus(code: Int, data: Data?)

    /// The response (200 OK) does not contain data.
    case noData

    /// Error from `RequestBuildable.buildRequest()`. The `error` is ignored upon evaluating equality.
    case requestFactoryError(Error)

    /// Error from `ResponseConvertible.convert(data:)`. The `error` is ignored upon evaluating equality.
    case responseConversionError(Error)

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
        case .requestFactoryError(let error),
             .responseConversionError(let error):
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
             (.noData, .noData),
             (.requestFactoryError, .requestFactoryError),
             (.responseConversionError, .responseConversionError):
            return true
        case (.notHttpResponse(let leftResponse), .notHttpResponse(let rightResponse)):
            return leftResponse == rightResponse
        case (.httpStatus(let leftCode, _), .httpStatus(let rightCode, _)):
            return leftCode == rightCode
        default:
            return false
        }
    }
}
