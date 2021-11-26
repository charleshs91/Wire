import Foundation

/**
 Defines the `convert(data:)` method that consumes a chunk of data and
 outputs a fallible result wrapping the transformed value of type `Output`.
 */
public protocol ResponseConvertible {
    /// The type to which the input data is transformed.
    associatedtype Output

    /// Transforms a chunk of data into a value typed `Output` and returns as a fallible result.
    /// - Parameter data: The data to be converted.
    func convert(data: Data) -> Result<Output, Error>
}
