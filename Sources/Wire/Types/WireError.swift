import Foundation

public enum WireError: LocalizedError {
    /// The URL string is invalid. The associated value represents the URL string,
    /// which is compared upon evaluating equality.
    case invalidURLString(String)

    /// Error from `RequestBuildable.buildRequest()`. The `error` is ignored upon evaluating equality.
    case requestBuilder(Error)

    /// Error related to URLSession. The associated ``DataTaskClient/PerformError`` value is considered upon equality evaluation.
    case dataTaskClient(DataTaskClient.Error)

    /// Error from `ResponseConvertible.convert(data:)`. The `error` is ignored upon evaluating equality.
    case responseConverter(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURLString(let urlString):
            return "`\(urlString)` is not a valid URL."
        case .requestBuilder(let error):
            return "Request builder error: \(error.localizedDescription)"
        case .dataTaskClient(let requestError):
            return requestError.localizedDescription
        case .responseConverter(let error):
            return "Response converter error: \(error.localizedDescription)"
        }
    }
}

extension WireError: Equatable {
    public static func ==(lhs: WireError, rhs: WireError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURLString(let ls), .invalidURLString(let rs)):
            return ls == rs
        case (.dataTaskClient(let le), .dataTaskClient(let re)):
            return le == re
        case (.requestBuilder, .requestBuilder),
             (.responseConverter, .responseConverter):
            return true
        default:
            return false
        }
    }
}

public extension Error {
    var wireError: WireError? {
        return self as? WireError
    }

    var wireDataTaskClientError: DataTaskClient.Error? {
        guard let wireError = wireError,
              case .dataTaskClient(let error) = wireError 
        else { return nil }

        return error
    }

    var wireRequestBuilderError: Error? {
        guard let wireError = wireError,
              case .requestBuilder(let builderError) = wireError
        else { return nil }

        return builderError
    }

    var wireResponseConverterError: Error? {
        guard let wireError = wireError,
              case .responseConverter(let converterError) = wireError
        else { return nil }

        return converterError
    }
}
