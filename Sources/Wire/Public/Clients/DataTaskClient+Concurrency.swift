#if swift(>=5.5)
import Foundation

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, OSX 12.0, *)
extension DataTaskClient {
    /// Asynchronously returns an object obtained via `URLSession`.
    /// - Returns: Value of type `Output` defined in `ResponseConvertible`.
    /// - Throws: Error of type `BaseError`.
    public func object<T: RequestBuildable, U: ResponseConvertible>(
        with requestFactory: T,
        objectConverter: U
    ) async throws -> U.Output {
        let data = try await self.data(with: requestFactory)

        switch objectConverter.convert(data: data) {
        case .failure(let error):
            throw BaseError.responseConversionError(error)
        case .success(let output):
            return output
        }
    }

    /// Asynchronously returns a chunk of data obtained via `URLSession`.
    /// - Throws: Error of type `BaseError`.
    public func data<T: RequestBuildable>(
        with requestFactory: T
    ) async throws -> Data {
        switch requestFactory.buildRequest() {
        case .failure(let error):
            throw BaseError.requestBuildingError(error)
        case .success(let urlRequest):
            do {
                let (data, response) = try await session.data(for: urlRequest)
                return try process(data: data, response: response, error: nil).get()
            } catch let error as BaseError {
                throw error
            } catch {
                throw BaseError.sessionError(error)
            }
        }
    }
}
#endif
