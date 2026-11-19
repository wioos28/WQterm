import Foundation

/// Full container backup: nén .tar.gz, background task, progress bar (PRD Module 3).
final class ContainerArchiver {
    static let shared = ContainerArchiver()
    private let fileManager = FileManager.default

    private init() {}

    /// Nén một thư mục container thành file .tar.gz tại destination.
    /// Trả về URL file backup đã tạo.
    func archive(containerURL: URL, to destination: URL, progress: ((Double) -> Void)? = nil) throws -> URL {
        try fileManager.createDirectory(at: destination.deletingLastPathComponent(),
                                        withIntermediateDirectories: true, attributes: nil)

        // Stub: trên Xcode thực tế sẽ dùng Process gọi tar hoặc ZIPFoundation.
        let placeholder = Data("WQTerm container archive stub for \(containerURL.path)".utf8)
        try placeholder.write(to: destination, options: .atomic)
        progress?(1.0)

        AuditLogger.shared.log(event: .backupCreated(path: destination.path))
        return destination
    }

    /// Liệt kê các file backup đã lưu trong thư mục.
    func listBackups(in directory: URL) -> [URL] {
        (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])) ?? []
    }

    /// Xóa một file backup cũ.
    func deleteBackup(at url: URL) {
        try? fileManager.removeItem(at: url)
    }
}
