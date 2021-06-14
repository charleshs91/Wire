import Foundation

extension Result {
    static func mapThrowable(expression: () throws -> Success) -> Result<Success, Error> {
        do {
            return .success(try expression())
        } catch {
            return .failure(error)
        }
    }
}
