import Foundation

/// Ghi nhật ký mọi thao tác ghi (PRD Module 6: Audit log). Xuất được ra file.
enum AuditEvent: Equatable {
    case appLaunch
    case compatibilityCheck(status: String)
    case worseQueryMounted(bundleID: String)
    case worseQueryExtensionFailed(bundleID: String)
    case sandboxMounted(bundleID: String)
    case sandboxMountFailed(bundleID: String, error: String)
    case writeAheadSnapshot(command: String, target: String)
    case fileWrite(path: String)
    case fileDelete(path: String)
    case backupCreated(path: String)
    case backupRestored(path: String)
    case aiCLICall(tool: String)
    case panicWipe
    case faceIDLock
    case faceIDUnlock
    case safeModeToggled(enabled: Bool)

    var name: String {
        switch self {
        case .appLaunch: return "app_launch"
        case .compatibilityCheck: return "compatibility_check"
        case .worseQueryMounted: return "worse_query_mounted"
        case .worseQueryExtensionFailed: return "worse_query_extension_failed"
        case .sandboxMounted: return "sandbox_mounted"
        case .sandboxMountFailed: return "sandbox_mount_failed"
        case .writeAheadSnapshot: return "write_ahead_snapshot"
        case .fileWrite: return "file_write"
        case .fileDelete: return "file_delete"
        case .backupCreated: return "backup_created"
        case .backupRestored: return "backup_restored"
        case .aiCLICall: return "ai_cli_call"
        case .panicWipe: return "panic_wipe"
        case .faceIDLock: return "face_id_lock"
        case .faceIDUnlock: return "face_id_unlock"
        case .safeModeToggled: return "safe_mode_toggled"
        }
    }
}

final class AuditLogger {
    static let shared = AuditLogger()
    private let queue = DispatchQueue(label: "com.wqterm.audit", qos: .utility)
    private let logURL: URL?

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        logURL = docs?.appendingPathComponent(".terminal/audit.log", isDirectory: false)
        if let url = logURL {
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                     withIntermediateDirectories: true, attributes: nil)
        }
    }

    func log(event: AuditEvent) {
        queue.async {
            let timestamp = ISO8601DateFormatter().string(from: Date())
            let line = "\(timestamp) [\(event.name)]\n"
            guard let url = self.logURL, let data = line.data(using: .utf8) else { return }
            if FileManager.default.fileExists(atPath: url.path) {
                if let handle = try? FileHandle(forWritingTo: url) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                try? data.write(to: url, options: .atomic)
            }
        }
    }

    /// Xuất toàn bộ log ra một file (để share / xem lại).
    func exportLog() -> URL? {
        guard let url = logURL, FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }

    func clearLog() {
        guard let url = logURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
