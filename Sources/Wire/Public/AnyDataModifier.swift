import Foundation

public struct AnyDataModifier: DataModifiable {
    public typealias Transform = (Data) -> Result<Data, Error>

    private let transform: Transform

    public init(transform: @escaping Transform) {
        self.transform = transform
    }

    public init<T: DataModifiable>(_ modifier: T) {
        self.transform = { input in
            modifier.modify(input)
        }
    }

    public func modify(_ input: Data) -> Result<Data, Error> {
        return transform(input)
    }
}
