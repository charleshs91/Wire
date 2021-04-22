import Foundation

public struct Resource: RequestBuildable {
    public let url: URL
    public let headers: [HTTP.Header]
    public let method: HTTP.Method
    public let body: Data?

    public init?(urlString: String, headers: [HTTP.Header] = [], method: HTTP.Method = .get, body: Data? = nil) {
        guard let url = URL(string: urlString) else { return nil }
        self = Resource(url: url, headers: headers, method: method, body: body)
    }

    public init(url: URL, headers: [HTTP.Header], method: HTTP.Method, body: Data?) {
        self.url = url
        self.headers = headers
        self.method = method
        self.body = body
    }

    public func buildRequest() -> Result<URLRequest, Error> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        headers.forEach { $0.modify(request: &urlRequest) }
        urlRequest.httpBody = body
        return .success(urlRequest)
    }
}

extension Resource {
    public func getData(completion: @escaping (Result<Data, Error>) -> Void) {
        DataTaskClient.shared.retrieveData(request: self, completion: completion)
    }

    public func getJSON<T:Decodable>(ofType: T.Type,
                                     using decoder: JSONDecoder = JSONDecoder(),
                                     completion: @escaping (Result<T, Error>) -> Void)
    {
        DataTaskClient.shared.retrieveResponse(request: self,
                                               dataConverter: JSONConverter<T>(decoder: decoder),
                                               completion: completion)
    }
}
