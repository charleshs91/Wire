import Foundation

/// Concrete implementation of `DataModifiable`.
public struct AnyDataModifiable: DataModifiable {
    public typealias Transform = (Data) -> Result<Data, Error>

    private let transform: Transform

    public init(transform: @escaping Transform) {
        self.transform = transform
    }

    public init<T: DataModifiable>(_ modifier: T) {
        self.transform = { inputData in
            return modifier.modify(inputData)
        }
    }

    public func modify(_ inputData: Data) -> Result<Data, Error> {
        return transform(inputData)
    }
}
