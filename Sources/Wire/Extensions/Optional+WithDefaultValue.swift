import Foundation

protocol WithDefaultValue {
    static var defaultValue: Self { get }
}

extension Optional where Wrapped: WithDefaultValue {
    func unboxed(fallback defaultValue: Wrapped = Wrapped.defaultValue) -> Wrapped {
        return self ?? defaultValue
    }
}

extension Data: WithDefaultValue {
    static var defaultValue: Data { Data() }
}
