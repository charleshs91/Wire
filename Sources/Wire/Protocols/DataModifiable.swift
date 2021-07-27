import Foundation

/**
 Defines the `modify(_:)` method that consumes a data and
 outputs a failable result enclosing the modified data.
 */
public protocol DataModifiable {
    /// Modifies a chunk of data and returns a failable result wrapping the modified data.
    /// - Parameter input: A chunk of data being modified.
    func modify(_ input: Data) -> Result<Data, Error>
}
