import Foundation

extension Optional {
    func mapNil(as fallback: Wrapped) -> Wrapped {
        return self ?? fallback
    }
}
