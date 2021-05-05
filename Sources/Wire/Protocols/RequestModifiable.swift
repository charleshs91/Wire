import Foundation

/// Capable of modifying `URLRequest`.
public protocol RequestModifiable {
    /// Modifies a `URLRequest` and returns as a `Result` value.
    /// - Parameter request: The request to be modified.
    func modify(_ request: URLRequest) -> Result<URLRequest, Error>
}

extension RequestModifiable {
    public func set(headers: [String: String], to request: inout URLRequest, mergesField: Bool = true) {
        let headers = headers.map { key, value in
            HTTPHeader.other(key: key, value: value)
        }
        set(headers: headers, to: &request, mergesField: mergesField)
    }

    public func set(headers: [HTTPHeader], to request: inout URLRequest, mergesField: Bool = true) {
        headers.forEach { header  in
            header.modify(request: &request, mergesField: mergesField)
        }
    }

    public func set(body: Data?, to request: inout URLRequest) {
        request.httpBody = body
    }
}

extension Data: RequestModifiable {
    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        var req = request
        req.httpBody = self
        return .success(req)
    }
}
