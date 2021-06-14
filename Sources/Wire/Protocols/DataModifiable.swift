import Foundation

/// Capable of modifying data and transforming into a result value.
public protocol DataModifiable {
    /// Modifies a chunk of data and returns as a result value.
    /// - Parameter inputData: A chunk of data being modified.
    func modify(_ inputData: Data) -> Result<Data, Error>
}
