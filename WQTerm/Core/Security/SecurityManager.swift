import Foundation

/// Tổng hợp trạng thái bảo mật dùng bởi UI (PRD Module 6).
final class SecurityManager: ObservableObject {
    static let shared = SecurityManager()
    @Published var isLocked: Bool = false

    private init() {
        // Khóa ban đầu nếu FaceID bật và chưa xác thực
        if FaceIDLock.shared.isEnabled && !FaceIDLock.shared.isUnlocked {
            isLocked = true
        }
    }

    func unlock(completion: @escaping (Bool) -> Void) {
        FaceIDLock.shared.authenticate { success in
            DispatchQueue.main.async {
                self.isLocked = !success
                completion(success)
            }
        }
    }
}
