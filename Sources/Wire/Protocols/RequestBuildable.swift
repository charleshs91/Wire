import Foundation

/**
 Defines the `buildRequest()` method which outputs a fallible result enclosing a `URLRequest` instance.
 */
public protocol RequestBuildable {
    /// Returns a fallible result wrapping a `URLRequest`.
    func buildRequest() -> Result<URLRequest, Error>
}

extension URLRequest: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        return .success(self)
    }
}

extension URL: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        return .success(URLRequest(url: self))
    }
}

extension String: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        guard let url = URL(string: self) else {
            return .failure(WireError.invalidURLString(self))
        }
        return .success(URLRequest(url: url))
    }
}
