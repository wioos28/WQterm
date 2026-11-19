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

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
        process.arguments = ["-czf", destination.path, "-C", containerURL.deletingLastPathComponent().path, containerURL.lastPathComponent]
        process.currentDirectoryURL = containerURL.deletingLastPathComponent()

        let errorPipe = Pipe()
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                progress?(1.0)
                AuditLogger.shared.log(event: .backupCreated(path: destination.path))
                return destination
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorMsg = String(data: errorData, encoding: .utf8) ?? "Lỗi nén tar.gz không xác định (mã \(process.terminationStatus))"
                throw NSError(domain: "WQTerm.ContainerArchiver", code: Int(process.terminationStatus),
                              userInfo: [NSLocalizedDescriptionKey: errorMsg])
            }
        } catch let error as NSError {
            throw error
        } catch {
            throw NSError(domain: "WQTerm.ContainerArchiver", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        }
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
