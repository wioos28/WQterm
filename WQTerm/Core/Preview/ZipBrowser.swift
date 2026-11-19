import Foundation

/// ZIP browser: liệt kê nội dung không cần giải nén (PRD Module 7.2, ZIPFoundation).
final class ZipBrowser {
    static let shared = ZipBrowser()
    private init() {}

    struct ZipEntry {
        let name: String
        let size: UInt64
        let isDirectory: Bool
    }

    /// Liệt kê nội dung ZIP (stub; trên Xcode dùng ZIPFoundation).
    func listEntries(url: URL) -> [ZipEntry] {
        // Placeholder: trả về metadata đơn giản
        return [
            ZipEntry(name: "placeholder.txt", size: 0, isDirectory: false)
        ]
    }
}
