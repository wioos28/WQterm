import Foundation

/// JIT (PRD Module 8.2): tích hợp StikDebug qua URL scheme.
/// JIT không bắt buộc — các tính năng cơ bản vẫn chạy không cần JIT.
final class JITManager: ObservableObject {
    static let shared = JITManager()
    @Published var status: JITStatus = .unavailable

    enum JITStatus: String {
        case off = "off"
        case on = "on"
        case unavailable = "unavailable"
    }

    private init() {
        self.status = .unavailable
    }

    /// Mở Settings tab JIT và gọi StikDebug URL scheme.
    func enableJITURL() -> URL? {
        URL(string: "stikdebug://enable-jit?bundle-id=com.wqterm.app")
    }

    func refreshStatus() {
        // Stub: kiểm tra xem StikDebug đã bật LocalDevVPN chưa.
        status = .off
    }
}
