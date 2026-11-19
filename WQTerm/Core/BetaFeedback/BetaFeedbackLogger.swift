import Foundation
import OSLog

/// Ghi log hệ thống cho Beta Feedback (dùng OSLog).
enum BetaFeedbackLog {
    static let subsystem = "com.wqterm.betafeedback"
    static let uiLogger = OSLog(subsystem: subsystem, category: "UI")
    static let systemLogger = OSLog(subsystem: subsystem, category: "System")
    static let crashLogger = OSLog(subsystem: subsystem, category: "Crash")

    static func ui(_ message: String) {
        os_log("%{public}@", log: uiLogger, type: .info, message)
    }

    static func system(_ message: String) {
        os_log("%{public}@", log: systemLogger, type: .info, message)
    }

    static func crash(_ message: String) {
        os_log("%{public}@", log: crashLogger, type: .fault, message)
    }
}
