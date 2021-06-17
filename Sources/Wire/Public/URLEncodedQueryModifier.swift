import Foundation

public struct URLEncodedQueryModifier: RequestModifiable {
    public enum Destination {
        /// The encoded query string is appended to the URL.
        case queryString
        /// The encoded query string is wrapped into the body of the HTTP request.
        case httpBody
    }

    public enum Error: LocalizedError {
        /// Indicates the `URL` of `URLRequest` is nil.
        case requestContainsEmptyURL
        /// Indicates failure parsing the `URL` into `URLComponents`.
        case failToParseComponents
    }

    private let queryItems: [URLQueryItem]
    private let destination: Destination
    private let allowedCharacters: CharacterSet

    public init(queryItems: [URLQueryItem], destination: Destination, allowedCharacters: CharacterSet = .rfc3986Allowed) {
        self.queryItems = queryItems
        self.destination = destination
        self.allowedCharacters = allowedCharacters
    }

    public init(parameters: [String: String], destination: Destination, allowedCharacters: CharacterSet = .rfc3986Allowed) {
        self.init(queryItems: parameters.map(URLQueryItem.init), destination: destination, allowedCharacters: allowedCharacters)
    }

    public func modify(_ request: URLRequest) -> Result<URLRequest, Swift.Error> {
        var req = request

        switch destination {
        case .queryString:
            return .mapThrowable {
                try adaptQueryString(to: &req)
                return req
            }
        case .httpBody:
            adaptHttpBody(to: &req)
            return .success(req)
        }
    }

    private func adaptQueryString(to req: inout URLRequest) throws {
        guard let url = req.url else {
            throw Error.requestContainsEmptyURL
        }
        guard var components = URLComponents.init(url: url, resolvingAgainstBaseURL: true) else {
            throw Error.failToParseComponents
        }

        let percentEncodedQueryItems = queryItems.map { it in
            URLQueryItem(name: escape(it.name), value: it.value.map { escape($0) } )
        }
        // Append percent-encoded query items to the existing array in components
        components.percentEncodedQueryItems = [components.percentEncodedQueryItems ?? [], percentEncodedQueryItems].flatMap { $0 }

        req.url = components.url
    }

    private func adaptHttpBody(to req: inout URLRequest) {
        let queryString = queryItems
            .compactMap { it in
                it.value.map { "\(escape(it.name))=\(escape($0))" }
            }
            .joined(separator: "&")

        ContentType.urlEncodedForm.apply(to: &req)
        req.httpBody = queryString.data(using: .utf8)
    }

    private func escape(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? string
    }
}
