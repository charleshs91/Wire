import Foundation

public struct Request<Output> {
    public let requestFactory: RequestBuildable
    public let requestModifiers: [RequestModifier]
    public let dataModifiers: [DataModifier]

    private let dataConverter: (Data) throws -> Output

    public init(requestFactory: RequestBuildable,
                requestModifiers: [RequestModifier] = [],
                dataModifiers: [DataModifier] = [],
                dataConverter: @escaping (Data) throws -> Output)
    {
        self.requestFactory = requestFactory
        self.requestModifiers = requestModifiers
        self.dataModifiers = dataModifiers
        self.dataConverter = dataConverter
    }
}

extension Request: RequestBuildable {
    public func buildRequest() -> Result<URLRequest, Error> {
        switch requestFactory.buildRequest() {
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
}

extension Request: ResponseConvertible {
    public func convert(data: Data) -> Result<Output, Error> {
        switch modifyResponse(data: data) {
        case .failure(let error):
            return .failure(error)
        case .success(let data):
            do {
                let output = try dataConverter(data)
                return .success(output)
            } catch {
                return .failure(error)
            }
        }
    }

    private func modifyResponse(data: Data) -> Result<Data, Error> {
        for modifier in dataModifiers {
            return modifier.modify(data)
        }
        // Return the original data when `responseModifiers` is empty.
        return .success(data)
    }
}
