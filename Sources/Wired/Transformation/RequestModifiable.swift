import Foundation

public protocol RequestModifiable {
    func modify(_ request: URLRequest) -> Result<URLRequest, Error>
}
