import Foundation

extension Result {
    /// Executes a throwable expression and returns as a `Result` instance.
    static func mapThrowable(expression: () throws -> Success) -> Result<Success, Error> {
        do {
            return .success(try expression())
        } catch {
            return .failure(error)
        }
    }
}
