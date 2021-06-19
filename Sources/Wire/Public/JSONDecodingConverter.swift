import Foundation

/// A converter that turns data into a `Decodable` object via `JSONDecoder`.
public struct JSONDecodingConverter<Output: Decodable>: ResponseConvertible {
    private let decode: (Data) throws -> Output

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decode = { data in
            try decoder.decode(Output.self, from: data)
        }
    }

    public func convert(data: Data) -> Result<Output, Error> {
        return .init(catching: {
            return try decode(data)
        })
    }
}
