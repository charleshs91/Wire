import Foundation

public struct AnyResponseConverter<Output>: ResponseConvertible {
    public typealias Transform = (Data) -> Result<Output, Error>

    private let transform: Transform

    public init(transform: @escaping Transform) {
        self.transform = transform
    }

    public init<T: ResponseConvertible>(_ converter: T) where T.Output == Output {
        self.transform = { data in
            converter.convert(data: data)
        }
    }

    public func convert(data: Data) -> Result<Output, Error> {
        return transform(data)
    }
}
