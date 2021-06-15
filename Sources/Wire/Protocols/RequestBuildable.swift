import Foundation

/// Defines the `buildRequest()` method which outputs a failable result enclosing a `URLRequest` instance.
public protocol RequestBuildable {
    /// Returns a failable result wrapping a `URLRequest` on success.
    func buildRequest() -> Result<URLRequest, Error>
}

// MARK: Compatible with URLRequest
extension URLRequest: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        return .success(self)
    }
}

// MARK: Compatible with URL
extension URL: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        return .success(URLRequest(url: self))
    }
}

// MARK: Compatible with URL
extension String: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        guard let url = URL(string: self) else {
            return .failure(BaseError.invalidURLString(self))
        }
        return .success(URLRequest(url: url))
    }
}
