import Foundation

public enum BaseError: LocalizedError {
    /// The URL string is invalid. The associated value represents the URL string,
    /// which is compared upon evaluating equality.
    case invalidURLString(String)

    /// Error from `RequestBuildable.buildRequest()`. The `error` is ignored upon evaluating equality.
    case buildRequestError(Error)

    /// Error related to URLSession. The associated ``DataTaskClient/RequestError`` value is considered upon equality evaluation.
    case performError(DataTaskClient.PerformerError)

    /// Error from `ResponseConvertible.convert(data:)`. The `error` is ignored upon evaluating equality.
    case convertResponseError(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURLString(let urlString):
            return "`\(urlString)` is not a valid URL."
        case .performError(let requestError):
            return requestError.localizedDescription
        case .buildRequestError(let error):
            return "Request builder error: \(error.localizedDescription)"
        case .convertResponseError(let error):
            return "Response converter error: \(error.localizedDescription)"
        }
    }
}

extension BaseError: Equatable {
    public static func ==(lhs: BaseError, rhs: BaseError) -> Bool {
        switch (lhs, rhs) {
        // Associate value considered
        case (.invalidURLString(let leftString), .invalidURLString(let rightString)):
            return leftString == rightString
        case (.performError(let le), .performError(let re)):
            return le == re
        // No associate value or not considered
        case (.buildRequestError, .buildRequestError),
             (.convertResponseError, .convertResponseError):
            return true
        default:
            return false
        }
    }
}
