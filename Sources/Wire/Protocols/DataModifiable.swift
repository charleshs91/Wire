import Foundation

/// Defines the `modify(_:)` method which takes a data as an input and
/// outputs a failable result enclosing the modified data.
public protocol DataModifiable {
    /// Modifies a chunk of data and returns a failable result wrapping the modified data on success.
    /// - Parameter inputData: A chunk of data being modified.
    func modify(_ inputData: Data) -> Result<Data, Error>
}
