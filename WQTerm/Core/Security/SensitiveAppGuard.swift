import Foundation

/// SensitiveAppGuard: dialog đỏ khi mount app nhạy cảm (banking, crypto, password manager).
/// Danh sách bundle-id mẫu — người dùng có thể bổ sung trong Settings.
final class SensitiveAppGuard {
    static let shared = SensitiveAppGuard()
    private let defaults = UserDefaults(suiteName: "group.com.wqterm.app") ?? UserDefaults.standard
    private let key = "WQTerm.SensitiveAppBundleIDs"

    /// Danh sách mặc định (có thể mở rộng)
    private let defaultsList = [
        "com.example.banking",
        "com.example.cryptowallet",
        "com.example.passwordmanager"
    ]

    var sensitiveBundleIDs: [String] {
        get { defaults.stringArray(forKey: key) ?? defaultsList }
        set { defaults.set(newValue, forKey: key) }
    }

    func isSensitive(_ bundleID: String) -> Bool {
        sensitiveBundleIDs.contains(bundleID)
    }

    func warningMessage(for bundleID: String) -> String {
        return "⚠️ \(bundleID) là ứng dụng nhạy cảm (banking / crypto / password manager).\nChỉ truy cập trên thiết bị cá nhân và có sự cho phép bằng văn bản."
    }
}
