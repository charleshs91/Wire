import Foundation

enum LocalError: LocalizedError {
    case invalidURLString(String)

    var errorDescription: String? {
        switch self {
        case .invalidURLString(let urlString):
            return "`\(urlString)` is not a valid URL."
        }
    }
}
