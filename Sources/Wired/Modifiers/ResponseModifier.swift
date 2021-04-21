import Foundation

public protocol ResponseModifier {
    func modify(_ inputData: Data) -> Result<Data, Error>
}

public struct AnyResponseModifier: ResponseModifier {
    private let _modify: (Data) -> Result<Data, Error>

    public init<T: ResponseModifier>(_ modifier: T) {
        _modify = { inputData in
            return modifier.modify(inputData)
        }
    }

    public func modify(_ inputData: Data) -> Result<Data, Error> {
        return _modify(inputData)
    }
}
