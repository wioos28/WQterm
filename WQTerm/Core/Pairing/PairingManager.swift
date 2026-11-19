import Foundation

/// Pairing (PRD Module 8.1): tạo composite pairing file (RPPairing + lockdown)
/// cho SideStore/StikDebug/LiveContainer. Kiểm tra định kỳ mỗi foreground.
final class PairingManager: ObservableObject {
    static let shared = PairingManager()
    @Published var isPaired: Bool = false
    @Published var pairingCode: String = ""

    private let defaults = UserDefaults(suiteName: "group.com.wqterm.app") ?? UserDefaults.standard
    private let pairedKey = "WQTerm.Pairing.IsPaired"

    private init() {
        self.isPaired = defaults.bool(forKey: pairedKey)
        self.pairingCode = Self.generateCode()
    }

    /// Tạo mã hiển thị cho người dùng nhập trong Settings › Developer Mode.
    static func generateCode() -> String {
        String((0..<6).map { _ in Int.random(in: 0...9) })
    }

    func refreshCode() {
        pairingCode = Self.generateCode()
    }

    func markPaired() {
        isPaired = true
        defaults.set(true, forKey: pairedKey)
        AuditLogger.shared.log(event: .appLaunch) // pairing event logged elsewhere
    }

    /// Tạo composite pairing file chứa RPPairing + lockdown (stub).
    func exportCompositePairingFile() -> URL? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("WQTerm.pairing.mobiledevicepairing", isDirectory: false)
        let content = "<?xml version=\"1.0\"?><plist><dict><key>RPPairing</key><true/><key>Lockdown</key><true/></dict></plist>"
        try? content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    /// Kiểm tra định kỳ (foreground), hiện "Pair again" nếu cần.
    func recheck() {
        isPaired = defaults.bool(forKey: pairedKey)
    }
}
