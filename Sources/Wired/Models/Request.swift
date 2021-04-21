import Foundation

public protocol Request: RequestConvertible {
    var urlRequestBuilder: RequestConvertible { get }
    var requestModifiers: [RequestModifier] { get }
    var responseModifiers: [ResponseModifier] { get }
}

extension Request {
    public func buildRequest() -> Result<URLRequest, Error> {
        switch urlRequestBuilder.buildRequest() {
        case .success(let urlRequest):
            for modifier in requestModifiers {
                return modifier.modify(urlRequest)
            }
            // Return the original URLRequest when `requestModifiers` is empty.
            return .success(urlRequest)
        case .failure(let error):
            return .failure(error)
        }
    }

    public func convertResponse(data: Data) -> Result<Data, Error> {
        for modifier in responseModifiers {
            return modifier.modify(data)
        }
        // Return the original data when `responseModifiers` is empty.
        return .success(data)
    }
}
