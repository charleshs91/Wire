import Foundation

public enum BaseError: LocalizedError {
    /// The URL string is invalid. The associated value represents the URL string,
    /// which is compared upon evaluating equality.
    case invalidURLString(String)

    /// Error from `RequestBuildable.buildRequest()`. The `error` is ignored upon evaluating equality.
    case requestBuilder(Error)

    /// Error related to URLSession. The associated ``DataTaskClient/PerformError`` value is considered upon equality evaluation.
    case dataTaskPerformer(DataTaskClient.PerformError)

    /// Error from `ResponseConvertible.convert(data:)`. The `error` is ignored upon evaluating equality.
    case responseConverter(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURLString(let urlString):
            return "`\(urlString)` is not a valid URL."
        case .requestBuilder(let error):
            return "Request builder error: \(error.localizedDescription)"
        case .dataTaskPerformer(let requestError):
            return requestError.localizedDescription
        case .responseConverter(let error):
            return "Response converter error: \(error.localizedDescription)"
        }
    }
}

extension BaseError: Equatable {
    public static func ==(lhs: BaseError, rhs: BaseError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURLString(let ls), .invalidURLString(let rs)):
            return ls == rs
        case (.dataTaskPerformer(let le), .dataTaskPerformer(let re)):
            return le == re
        case (.requestBuilder, .requestBuilder),
             (.responseConverter, .responseConverter):
            return true
        default:
            return false
        }
    }
}
