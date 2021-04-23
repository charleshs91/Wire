import Foundation

public protocol RequestBuildable {
    /// Returns `URLRequest` wrapped by a `Result` value.
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
            return .failure(LocalError.invalidURLString(self))
        }
        return .success(URLRequest(url: url))
    }
}
