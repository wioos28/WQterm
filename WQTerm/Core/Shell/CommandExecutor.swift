import Foundation

/// Thực thi lệnh shell và hook write-ahead snapshot trước các lệnh ghi (PRD Module 1 & Module 3).
/// Trên iOS thực tế, lệnh được chạy qua Process/posix_spawn liên kết với ios_system (a-Shell fork).
final class CommandExecutor {
    static let shared = CommandExecutor()
    private let safeMode = SafeMode.shared
    private let fileManager = FileManager.default

    private init() {}

    /// Các từ khóa lệnh ghi cần trigger write-ahead backup trước khi chạy.
    private let writeKeywords: [String] = [
        ">", ">>", "rm ", "mv ", "cp ", "sed -i", "tee ", "dd ", "mkfs", "fdisk"
    ]

    /// Thực thi một lệnh shell trong thư mục làm việc chỉ định.
    /// Trả về (stdout, stderr). Nếu SafeMode bật và là lệnh ghi → từ chối.
    func execute(_ command: String, in workingDirectory: URL) -> (output: String, error: String?) {
        // SafeMode: chặn toàn bộ lệnh ghi
        if let blockReason = safeMode.guardWrite(command: command) {
            AuditLogger.shared.log(event: .fileWrite(path: workingDirectory.path))
            return ("", blockReason)
        }

        // Write-ahead snapshot: sao chép file đích trước khi lệnh ghi chạy
        if isWriteCommand(command) {
            SnapshotManager.shared.createWriteAheadSnapshot(for: command, cwd: workingDirectory.path)
        }

        // Thực thi lệnh qua Process (trên iOS cần link với ios_system / a-Shell binary).
        let result = runProcess(command: command, workingDirectory: workingDirectory.path)

        AuditLogger.shared.log(event: .fileWrite(path: workingDirectory.path))
        return result
    }

    private func isWriteCommand(_ command: String) -> Bool {
        let lower = command.lowercased()
        return writeKeywords.contains { lower.contains($0) }
    }

    // MARK: - Process execution

    private func runProcess(command: String, workingDirectory: String) -> (output: String, error: String?) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", command]
        process.currentDirectoryURL = URL(fileURLWithPath: workingDirectory)

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
            process.waitUntilExit()

            let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

            let output = String(data: stdoutData, encoding: .utf8) ?? ""
            let errorOutput = String(data: stderrData, encoding: .utf8) ?? ""

            if process.terminationStatus == 0 {
                return (output, errorOutput.isEmpty ? nil : errorOutput)
            } else {
                return (output, errorOutput.isEmpty ? "Lệnh thoát với mã \(process.terminationStatus)" : errorOutput)
            }
        } catch {
            return ("", "Không thể thực thi lệnh: \(error.localizedDescription)")
        }
    }
}
