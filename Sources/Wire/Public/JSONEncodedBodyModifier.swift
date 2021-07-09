import Foundation

public struct JSONEncodedBodyModifier: RequestModifiable {
    private let encode: () throws -> Data

    public init<Payload: Encodable>(payload: Payload, encoder: JSONEncoder = JSONEncoder()) {
        self.encode = {
            try encoder.encode(payload)
        }
    }

    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        return Result(catching: {
            var req = request
            ContentType.json.apply(to: &req)
            req.httpBody = try encode()
            return req
        })
    }
}
