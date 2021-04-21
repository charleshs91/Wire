import Foundation

public protocol ResponseConvertible {
    associatedtype Output
    func convert(data: Data) -> Result<Output, Error>
}
