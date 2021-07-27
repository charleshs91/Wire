import Foundation

public enum WireBaseError: LocalizedError {
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

extension WireBaseError: Equatable {
    public static func ==(lhs: WireBaseError, rhs: WireBaseError) -> Bool {
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

public extension Error {
    var wireBaseError: WireBaseError? {
        return self as? WireBaseError
    }

    var wirePerformError: DataTaskClient.PerformError? {
        guard let wireError = wireBaseError,
              case .dataTaskPerformer(let error) = wireError
        else { return nil }

        return error
    }

    var wireBuilderOrConverterError: Error? {
        return wireRequestBuilderError ?? wireResponseConverterError
    }

    var wireRequestBuilderError: Error? {
        guard let wireError = wireBaseError,
              case .requestBuilder(let error) = wireError
        else { return nil }

        return error
    }

    var wireResponseConverterError: Error? {
        guard let wireError = wireBaseError,
              case .responseConverter(let error) = wireError
        else { return nil }

        return error
    }
}
