import Foundation
import LocalAuthentication

/// Face ID lock + session timeout (PRD Module 6).
final class FaceIDLock: ObservableObject {
    static let shared = FaceIDLock()
    private let context = LAContext()
    private let defaults = UserDefaults(suiteName: "group.com.wqterm.app") ?? UserDefaults.standard
    private let enabledKey = "WQTerm.FaceID.Enabled"
    private let timeoutKey = "WQTerm.FaceID.TimeoutSeconds" // 0 = tắt

    @Published var isEnabled: Bool = false
    @Published var isUnlocked: Bool = false
    var timeoutSeconds: Int {
        get { defaults.integer(forKey: timeoutKey) }
        set { defaults.set(newValue, forKey: timeoutKey) }
    }

    private var lastUnlockTime: Date?

    private init() {
        self.isEnabled = defaults.bool(forKey: enabledKey)
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        defaults.set(enabled, forKey: enabledKey)
        if enabled { authenticate() }
    }

    func authenticate(completion: ((Bool) -> Void)? = nil) {
        guard isEnabled else {
            isUnlocked = true
            completion?(true)
            return
        }
        let reason = "Khóa WQTerm bằng Face ID"
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                self.isUnlocked = success
                if success {
                    self.lastUnlockTime = Date()
                    AuditLogger.shared.log(event: .faceIDUnlock)
                } else {
                    AuditLogger.shared.log(event: .faceIDLock)
                }
                completion?(success)
            }
        }
    }

    /// Kiểm tra timeout session. Nếu quá thời gian cho phép, yêu cầu mở khóa lại.
    func requireReAuthIfNeeded() -> Bool {
        guard isEnabled, let last = lastUnlockTime, timeoutSeconds > 0 else {
            return !isUnlocked
        }
        let elapsed = Date().timeIntervalSince(last)
        if elapsed > TimeInterval(timeoutSeconds) {
            isUnlocked = false
            return true
        }
        return false
    }
}
