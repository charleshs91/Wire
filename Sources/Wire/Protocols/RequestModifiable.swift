import Foundation

/// Defines the `modify(_:)` method which takes a request as an input and
/// outputs a failable result enclosing the modified request.
public protocol RequestModifiable {
    /// Modifies a `URLRequest` and returns a failable result wrapping the modified request on success.
    /// - Parameter request: The request being modified.
    func modify(_ request: URLRequest) -> Result<URLRequest, Error>
}
