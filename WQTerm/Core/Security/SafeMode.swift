import Foundation

/// SafeMode: nút gạt — chỉ cho đọc, chặn mọi lệnh ghi (PRD Module 6).
final class SafeMode: ObservableObject {
    static let shared = SafeMode()
    private let defaults = UserDefaults(suiteName: "group.com.wqterm.app") ?? UserDefaults.standard
    private let key = "WQTerm.SafeMode.Enabled"

    @Published var isEnabled: Bool

    private init() {
        self.isEnabled = defaults.bool(forKey: key)
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        defaults.set(enabled, forKey: key)
        AuditLogger.shared.log(event: .safeModeToggled(enabled: enabled))
    }

    /// Kiểm tra trước khi thực hiện lệnh ghi. Trả về nil nếu được phép,
    /// hoặc lý do từ chối nếu SafeMode đang bật.
    func guardWrite(command: String) -> String? {
        guard isEnabled else { return nil }
        return "SafeMode đang bật: mọi lệnh ghi bị chặn. Tắt SafeMode trong Settings để tiếp tục."
    }
}
