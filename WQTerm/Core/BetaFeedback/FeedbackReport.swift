import Foundation
import UIKit

/// Loại lỗi người dùng chọn khi báo cáo.
enum FeedbackType: String, CaseIterable, Codable {
    case uiux = "UI/UX"
    case crash = "Crash"
    case logic = "Logic"

    var title: String {
        switch self {
        case .uiux: return "Lỗi giao diện / trải nghiệm người dùng"
        case .crash: return "Ứng dụng bị đóng bất ngờ (Crash)"
        case .logic: return "Lỗi logic / sai kết quả"
        }
    }
}

/// Một bản báo cáo lỗi từ người dùng.
struct FeedbackReport: Codable, Identifiable {
    let id: UUID
    let type: FeedbackType
    let description: String
    let timestamp: Date
    let deviceModel: String
    let systemVersion: String
    let appVersion: String
    var screenshotURL: URL?

    init(type: FeedbackType, description: String) {
        self.id = UUID()
        self.type = type
        self.description = description
        self.timestamp = Date()
        self.deviceModel = UIDevice.current.model
        self.systemVersion = UIDevice.current.systemVersion
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}
