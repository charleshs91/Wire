import Foundation

extension Data {
    func utf8String(or fallback: String) -> String {
        return String(data: self, encoding: .utf8) ?? fallback
    }
}
