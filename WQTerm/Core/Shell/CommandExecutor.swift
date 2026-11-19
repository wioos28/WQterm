import Foundation

/// Thực thi lệnh shell và hook write-ahead snapshot trước các lệnh ghi (PRD Module 1 & Module 3).
final class CommandExecutor {
    static let shared = CommandExecutor()
    private let safeMode = SafeMode.shared

    private init() {}

    /// Các từ khóa lệnh ghi cần trigger write-ahead backup trước khi chạy.
    private let writeKeywords: [String] = [
        ">", ">>", "rm", "mv", "cp ", "sed -i", "tee", "dd ", "mkfs", "fdisk"
    ]

    func execute(_ command: String, in workingDirectory: URL) -> (output: String, error: String?) {
        // SafeMode: chặn toàn bộ ghi
        if let blockReason = safeMode.guardWrite(command: command) {
            return ("", blockReason)
        }

        // Write-ahead snapshot: phân tích lệnh trước khi chạy
        if isWriteCommand(command) {
            SnapshotManager.shared.createWriteAheadSnapshot(for: command, cwd: workingDirectory.path)
        }

        // Thực thi thực tế (stub trên môi trường không có iOS SDK;
        // trên Xcode sẽ dùng Process / posix_spawn tới ios_system).
        let output = "[stub] \(command)\n"
        AuditLogger.shared.log(event: .fileWrite(path: workingDirectory.path))
        return (output, nil)
    }

    private func isWriteCommand(_ command: String) -> Bool {
        let lower = command.lowercased()
        return writeKeywords.contains { lower.contains($0) }
    }
}
