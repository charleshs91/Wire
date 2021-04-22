import Foundation

/// Capable of modifying `URLRequest`.
public protocol RequestModifiable {
    /// Modifies a `URLRequest` and returns as a `Result` value.
    /// - Parameter request: The request to be modified.
    func modify(_ request: URLRequest) -> Result<URLRequest, Error>
}
