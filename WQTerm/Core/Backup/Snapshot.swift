import Foundation

/// Write-ahead snapshot: copy file đích trước khi lệnh ghi chạy (PRD Module 3).
/// Giới hạn: snapshot tổng ≤ 2GB, chỉ backup file < 100MB, tự xóa cũ nhất.
final class SnapshotManager {
    static let shared = SnapshotManager()
    private let fileManager = FileManager.default
    private let maxTotalBytes: UInt64 = 2 * 1024 * 1024 * 1024 // 2GB
    private let maxFileBytes: UInt64 = 100 * 1024 * 1024       // 100MB

    private init() {}

    /// Tạo snapshot write-ahead cho file sẽ bị ghi đè bởi lệnh.
    func createWriteAheadSnapshot(for command: String, cwd: String) {
        // Phân tích đơn giản: trích xuất đường dẫn file từ lệnh (>, >>, rm, mv, cp, sed -i, tee)
        guard let targetPath = extractTargetPath(from: command, cwd: cwd) else { return }
        let targetURL = URL(fileURLWithPath: targetPath)
        guard fileManager.fileExists(atPath: targetURL.path) else { return }

        do {
            let attrs = try fileManager.attributesOfItem(atPath: targetURL.path)
            let fileSize = (attrs[.size] as? NSNumber)?.uint64 ?? 0
            guard fileSize <= maxFileBytes else {
                AuditLogger.shared.log(event: .writeAheadSnapshot(command: command, target: targetPath))
                return // file quá lớn, bỏ qua
            }
            let snapshotDir = try makeSnapshotDirectory()
            let dest = snapshotDir.appendingPathComponent(targetURL.lastPathComponent, isDirectory: false)
            try fileManager.copyItem(at: targetURL, to: dest)
            enforceTotalSizeLimit()
            AuditLogger.shared.log(event: .writeAheadSnapshot(command: command, target: targetPath))
        } catch {
            AuditLogger.shared.log(event: .writeAheadSnapshot(command: command, target: targetPath))
        }
    }

    private func extractTargetPath(from command: String, cwd: String) -> String? {
        // Heuristic đơn giản: lấy token cuối cùng trông như đường dẫn
        let tokens = command.split(separator: " ", omittingEmptySubsequences: true)
        guard let last = tokens.last else { return nil }
        var path = String(last)
        if !path.hasPrefix("/") {
            path = cwd + "/" + path
        }
        return path
    }

    private func makeSnapshotDirectory() throws -> URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let base = docs.appendingPathComponent(".terminal/backups/snapshots", isDirectory: true)
        try fileManager.createDirectory(at: base, withIntermediateDirectories: true, attributes: nil)
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let dir = base.appendingPathComponent(timestamp, isDirectory: true)
        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        return dir
    }

    private func enforceTotalSizeLimit() {
        // Tính tổng size snapshots, xóa thư mục cũ nhất nếu vượt 2GB
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let base = docs.appendingPathComponent(".terminal/backups/snapshots", isDirectory: true)
        guard let urls = try? fileManager.contentsOfDirectory(at: base, includingPropertiesForKeys: [.contentModificationDateKey], options: []) else { return }
        let sorted = urls.sorted {
            (try? $0.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast >
            (try? $1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
        }
        var total: UInt64 = 0
        for url in sorted {
            total += (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
        }
        var sortedAsc = sorted.reversed() // cũ nhất trước
        var idx = 0
        while total > maxTotalBytes, idx < sortedAsc.count {
            try? fileManager.removeItem(at: sortedAsc[idx])
            total -= (try? sortedAsc[idx].resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            idx += 1
        }
    }
}
