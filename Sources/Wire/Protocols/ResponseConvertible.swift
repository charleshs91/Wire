import Foundation

/**
 Defines the `convert(data:)` method that consumes a chunk of data and
 outputs a failable result wrapping the transformed value of type `Output`.
 */
public protocol ResponseConvertible {
    /// The type which the input data is transformed to.
    associatedtype Output

    /// Transforms a chunk of data into a value typed `Output` and returns as a failable result.
    /// - Parameter data: The data to be converted.
    func convert(data: Data) -> Result<Output, Error>
}
