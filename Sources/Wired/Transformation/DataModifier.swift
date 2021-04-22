import Foundation

/// Concrete implementation of `DataModifiable`.
public struct DataModifier: DataModifiable {
    public typealias Modifier = (Data) -> Result<Data, Error>

    private let modifier: Modifier

    public init(closure: @escaping Modifier) {
        modifier = closure
    }

    public init<T: DataModifiable>(_ modifier: T) {
        self.modifier = { inputData in
            return modifier.modify(inputData)
        }
    }

    public func modify(_ inputData: Data) -> Result<Data, Error> {
        return modifier(inputData)
    }
}
