import Foundation
import UIKit

/// Quản lý lưu và xuất bản báo cáo lỗi (nén .zip + UIActivityViewController).
final class FeedbackManager {
    static let shared = FeedbackManager()
    private let fileManager = FileManager.default
    private let reportsDirectory: URL

    private init() {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        reportsDirectory = docs.appendingPathComponent("BetaFeedback/Reports", isDirectory: true)
        try? fileManager.createDirectory(at: reportsDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    /// Lưu báo cáo ra file JSON và chụp ảnh màn hình kèm theo (nếu có).
    func saveReport(_ report: FeedbackReport, screenshot: UIImage?) -> URL? {
        let folder = reportsDirectory.appendingPathComponent(report.id.uuidString, isDirectory: true)
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)

        // Lưu JSON
        if let jsonData = try? JSONEncoder().encode(report) {
            let jsonURL = folder.appendingPathComponent("report.json", isDirectory: false)
            try? jsonData.write(to: jsonURL, options: .atomic)
        }

        // Lưu ảnh chụp màn hình
        if let screenshot = screenshot,
           let pngData = screenshot.pngData() {
            let imageURL = folder.appendingPathComponent("screenshot.png", isDirectory: false)
            try? pngData.write(to: imageURL, options: .atomic)
        }

        BetaFeedbackLog.system("Đã lưu báo cáo lỗi: \(report.id.uuidString) (\(report.type.rawValue))")
        return folder
    }

    /// Nén tất cả báo cáo thành một file .zip và trả về URL file zip.
    /// Dùng để xuất qua UIActivityViewController.
    func exportAllReportsZip() -> URL? {
        let zipName = "WQTerm_BetaFeedback_\(ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")).zip"
        let zipURL = reportsDirectory.deletingLastPathComponent().appendingPathComponent(zipName, isDirectory: false)

        let reportFolders = (try? fileManager.contentsOfDirectory(at: reportsDirectory, includingPropertiesForKeys: nil, options: [])) ?? []
        guard !reportFolders.isEmpty else { return nil }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        // zip -r <output.zip> <folder1> <folder2> ...
        var args = ["-r", zipURL.path]
        for folder in reportFolders {
            args.append(folder.path)
        }
        process.arguments = args
        process.currentDirectoryURL = reportsDirectory.deletingLastPathComponent()

        let errorPipe = Pipe()
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                BetaFeedbackLog.system("Xuất file zip báo cáo lỗi: \(zipURL.path)")
                return zipURL
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorMsg = String(data: errorData, encoding: .utf8) ?? "Lỗi nén zip không xác định (mã \(process.terminationStatus))"
                BetaFeedbackLog.system("Lỗi nén zip: \(errorMsg)")
                return nil
            }
        } catch {
            BetaFeedbackLog.system("Lỗi nén zip: \(error.localizedDescription)")
            return nil
        }
    }

    /// Lấy UIViewController root hiện tại để present UIActivityViewController.
    func presentShare(from viewController: UIViewController, fileURL: URL) {
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        // Trên iPad cần sourceView
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                        y: viewController.view.bounds.midY,
                                        width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        viewController.present(activityVC, animated: true, completion: nil)
    }
}
