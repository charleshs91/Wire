import Foundation

public protocol RequestConvertible {
    func buildRequest() -> Result<URLRequest, Error>
}

extension URLRequest: RequestConvertible {
    public func buildRequest() -> Result<URLRequest, Error> {
        return .success(self)
    }
}

extension URL: RequestConvertible {
    public func buildRequest() -> Result<URLRequest, Error> {
        return .success(URLRequest(url: self))
    }
}

extension String: RequestConvertible {
    public func buildRequest() -> Result<URLRequest, Error> {
        guard let url = URL(string: self) else {
            return .failure(LocalError.invalidURLString(self))
        }
        return .success(URLRequest(url: url))
    }
}
