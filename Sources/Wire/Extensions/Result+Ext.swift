import Foundation

extension Result {
    var error: Error? {
        if case .failure(let error) = self { return error }
        return nil
    }

    @discardableResult
    func onSuccess(_ expression: (Success) -> Void) -> Self {
        if case .success(let value) = self { expression(value) }
        return self
    }

    @discardableResult
    func onError(_ expression: (Failure) -> Void) -> Self {
        if case .failure(let error) = self { expression(error) }
        return self
    }
}
