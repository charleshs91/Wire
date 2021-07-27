import Foundation

public struct URLEncodedQueryModifier: RequestModifiable {
    public enum Destination {
        case url
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
        switch destination {
        case .url:
            return modifiedResultForURL(request)
        case .httpBody:
            return modifiedResultForHttpBody(request)
        }
    }

    private func modifiedResultForURL(_ req: URLRequest) -> Result<URLRequest, Swift.Error> {
        Result(catching: {
            var req = req
            var components = try buildURLComponents(from: req)
            appendPercentEncodedQueryItems(getPercentEncodedQueryItems(), to: &components)
            req.url = components.url
            return req
        })
    }

    private func buildURLComponents(from req: URLRequest) throws -> URLComponents {
        guard let url = req.url else {
            throw Error.requestContainsEmptyURL
        }
        guard let components = URLComponents.init(url: url, resolvingAgainstBaseURL: true) else {
            throw Error.failToParseComponents
        }
        return components
    }

    private func appendPercentEncodedQueryItems(_ queryItems: [URLQueryItem], to components: inout URLComponents) {
        components.percentEncodedQueryItems = [components.percentEncodedQueryItems ?? [], queryItems].flatMap { $0 }
    }

    private func getPercentEncodedQueryItems() -> [URLQueryItem] {
        queryItems.map { it in
            URLQueryItem(
                name: escape(it.name),
                value: it.value.map { escape($0) }
            )
        }
    }

    private func modifiedResultForHttpBody(_ req: URLRequest) -> Result<URLRequest, Swift.Error> {
        var req = req
        let queryString = getQueryString()
        ContentType.urlEncodedForm.apply(to: &req)
        req.httpBody = queryString.data(using: .utf8)
        return .success(req)
    }

    private func getQueryString() -> String {
        queryItems
            .compactMap { it in
                it.value.map { "\(escape(it.name))=\(escape($0))" }
            }
            .joined(separator: "&")
    }

    private func escape(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? string
    }
}
