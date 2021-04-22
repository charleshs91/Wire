import Foundation

/// Capable of modifying `Data`.
public protocol DataModifiable {
    /// Modifies a chunk of data and returns as a `Result` value.
    /// - Parameter inputData: The data to be modified.
    func modify(_ inputData: Data) -> Result<Data, Error>
}
