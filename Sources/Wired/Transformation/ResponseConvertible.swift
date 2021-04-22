import Foundation

/// Capable of converting `Data` into a generic `Output` value.
public protocol ResponseConvertible {
    /// Type of the converted result.
    associatedtype Output

    /// Converts `Data` into `Output`.
    /// - Parameter data: The data to be converted.
    func convert(data: Data) -> Result<Output, Error>
}
