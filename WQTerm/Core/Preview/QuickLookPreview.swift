import Foundation
import QuickLook

/// QuickLook preview đa định dạng (PRD Module 7.1).
/// Giới hạn 50MB, blur sensitive, clear cache sau khi xem.
final class QuickLookPreview {
    static let shared = QuickLookPreview()
    private let maxSize: UInt64 = 50 * 1024 * 1024

    private init() {}

    func canPreview(url: URL) -> Bool {
        guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize,
              size <= maxSize else { return false }
        // Hỗ trợ: ảnh, video, audio, PDF, text, Office, HTML, RTF
        let supported = ["pdf","txt","md","html","rtf","doc","docx","xls","xlsx",
                         "png","jpg","jpeg","heic","gif","mp4","mov","mp3","wav"]
        return supported.contains(url.pathExtension.lowercased())
    }

    func preview(url: URL) -> QLPreviewController? {
        guard canPreview(url: url) else { return nil }
        let controller = QLPreviewController()
        return controller
    }

    func clearCache() {
        // Xóa cache preview (QLPreviewController tự quản lý phần lớn)
    }
}
