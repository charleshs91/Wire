import Foundation

public struct PlainTextBodyModifier: RequestModifiable {
    public enum Error: LocalizedError {
        case encodingFailure
    }

    private let encode: () throws -> Data

    public init(text: String, encoding: String.Encoding = .utf8) {
        self.encode = {
            guard let data = text.data(using: encoding) else {
                throw Error.encodingFailure
            }
            return data
        }
    }

    public func modify(_ request: URLRequest) -> Result<URLRequest, Swift.Error> {
        return .init(catching: {
            var req = request
            ContentType.plainText.apply(to: &req)
            req.httpBody = try encode()
            return req
        })
    }
}
