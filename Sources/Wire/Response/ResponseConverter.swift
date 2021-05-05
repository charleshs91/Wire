import Foundation

/// Concrete implementation of `ResponseConvertible`.
public struct ResponseConverter<Output>: ResponseConvertible {
    public typealias Converter = (Data) -> Result<Output, Error>

    private let converter: Converter

    public init(closure: @escaping Converter) {
        self.converter = closure
    }

    public init<T: ResponseConvertible>(_ converter: T) where T.Output == Output {
        self.converter = { data in
            return converter.convert(data: data)
        }
    }

    public func convert(data: Data) -> Result<Output, Error> {
        return converter(data)
    }
}
