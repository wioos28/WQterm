import Foundation

/// Phục hồi backup với confirm 2 bước, preview danh sách file sẽ ghi đè (PRD Module 3).
final class RestoreManager {
    static let shared = RestoreManager()
    private let fileManager = FileManager.default

    private init() {}

    /// Preview danh sách file trong một thư mục snapshot sẽ bị ghi đè khi restore.
    /// Trả về danh sách URL tương đối so với Documents root.
    func previewRestore(from snapshotURL: URL) -> [URL] {
        guard let files = try? fileManager.contentsOfDirectory(at: snapshotURL, includingPropertiesForKeys: nil, options: []) else {
            return []
        }
        return files
    }

    /// Thực thi restore: sao chép tất cả file từ snapshot về Documents.
    /// Yêu cầu confirm 2 bước (đã được xử lý ở UI trước khi gọi hàm này).
    func restore(from snapshotURL: URL, to documentsURL: URL) throws {
        let files = try fileManager.contentsOfDirectory(at: snapshotURL, includingPropertiesForKeys: nil, options: [])
        for fileURL in files {
            let dest = documentsURL.appendingPathComponent(fileURL.lastPathComponent, isDirectory: false)
            // Write-ahead: backup file đích trước khi ghi đè (nếu tồn tại)
            if fileManager.fileExists(atPath: dest.path) {
                SnapshotManager.shared.createWriteAheadSnapshot(for: "restore overwrite", cwd: documentsURL.path)
            }
            try fileManager.copyItem(at: fileURL, to: dest)
            AuditLogger.shared.log(event: .fileWrite(path: dest.path))
        }
        AuditLogger.shared.log(event: .backupRestored(path: snapshotURL.path))
    }

    /// Xóa một snapshot cũ.
    func deleteSnapshot(at url: URL) throws {
        try fileManager.removeItem(at: url)
        AuditLogger.shared.log(event: .backupRestored(path: url.path))
    }
}

/// Quản lý tự backup/restore toàn bộ ~/.terminal/ thành file .wqterm-config.zip (SelfBackup).
final class SelfBackupManager {
    static let shared = SelfBackupManager()
    private let fileManager = FileManager.default

    private init() {}

    var terminalDir: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(".terminal", isDirectory: true)
    }

    /// Export toàn bộ .terminal thành file zip tại destination.
    func exportConfig(to destination: URL) throws -> URL {
        guard let terminalDir = terminalDir, fileManager.fileExists(atPath: terminalDir.path) else {
            throw BackupError.restoreCancelled
        }
        try fileManager.createDirectory(at: destination.deletingLastPathComponent(),
                                        withIntermediateDirectories: true, attributes: nil)
        // Stub nén zip: trên Xcode thực tế dùng ZIPFoundation/Process gọi zip.
        let placeholder = Data("WQTerm self-backup config stub for \(terminalDir.path)".utf8)
        try placeholder.write(to: destination, options: .atomic)
        AuditLogger.shared.log(event: .backupCreated(path: destination.path))
        return destination
    }

    /// Import file .wqterm-config.zip vào .terminal (ghi đè).
    func importConfig(from zipURL: URL, to documentsURL: URL) throws {
        // Stub: giải nén zip vào .terminal (trên Xcode dùng ZIPFoundation).
        AuditLogger.shared.log(event: .backupRestored(path: zipURL.path))
    }
}

// MARK: - Errors (moved here to avoid duplication)

enum BackupError: LocalizedError {
    case keychainFailure(status: Int)
    case snapshotLimitExceeded
    case fileTooLarge
    case restoreCancelled

    var errorDescription: String? {
        switch self {
        case .keychainFailure(let status): return "Keychain lỗi: \(status)"
        case .snapshotLimitExceeded: return "Vượt quá giới hạn snapshot tổng 2GB."
        case .fileTooLarge: return "File quá lớn (>100MB), không backup."
        case .restoreCancelled: return "Restore bị hủy bởi người dùng."
        }
    }
}