import Foundation

public protocol DataModifiable {
    func modify(_ inputData: Data) -> Result<Data, Error>
}
