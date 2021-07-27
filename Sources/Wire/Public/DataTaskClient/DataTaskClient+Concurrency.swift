#if swift(>=5.5)
import Foundation

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, OSX 12.0, *)
extension DataTaskClient {
    public func object<T, U>(with builder: T, objectConverter: U) async throws -> U.Output
    where T: RequestBuildable, U: ResponseConvertible {
        let data = try await self.data(with: builder)
        return try getResultOfResponseConversion(objectConverter, data: data).get()
    }

    public func data<T>(with builder: T) async throws -> Data
    where T: RequestBuildable {
        switch builder.buildRequest() {
        case .failure(let error):
            throw BaseError.requestProvider(error)
        case .success(let urlRequest):
            return try await asyncRetrieveData(urlRequest)
        }
    }

    private func asyncRetrieveData(_ urlRequest: (URLRequest)) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: urlRequest)
            return try mappingResult(data: data, response: response, error: nil).get()
        } catch let error as BaseError {
            throw error
        } catch {
            throw BaseError.taskPerformer(.sessionError(error))
        }
    }
}
#endif
