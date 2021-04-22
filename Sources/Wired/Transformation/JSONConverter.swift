import Foundation

public struct JSONConverter<T: Decodable>: ResponseConvertible {
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    public func convert(data: Data) -> Result<T, Error> {
        do {
            let output = try decoder.decode(T.self, from: data)
            return .success(output)
        } catch {
            return .failure(error)
        }
    }
}
