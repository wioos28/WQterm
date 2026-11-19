import Foundation

/// Quản lý nhiều phiên terminal (PRD Module 1: ShellSession).
/// Lưu trữ thư mục làm việc, lịch sử lệnh và delegates kết quả ra UI.
final class ShellSession: ObservableObject {
    static let shared = ShellSession()
    private let executor = CommandExecutor.shared
    private let fileManager = FileManager.default

    /// Thư mục làm việc hiện tại (mặc định là Documents của app).
    @Published var currentDirectory: URL
    /// Lịch sử các lệnh đã chạy (giới hạn 1000 mục).
    @Published var history: [String] = []
    /// Kết quả lệnh gần nhất để UI hiển thị.
    @Published var lastOutput: String = ""
    @Published var lastError: String? = nil

    private init() {
        self.currentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Chạy một lệnh shell, cập nhật history và last output.
    @discardableResult
    func run(_ command: String) -> (output: String, error: String?) {
        guard !command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ("", nil)
        }
        history.append(command)
        if history.count > 1000 { history.removeFirst(history.count - 1000) }

        let result = executor.execute(command, in: currentDirectory)
        lastOutput = result.output
        lastError = result.error
        return result
    }

    /// Thay đổi thư mục làm việc. Trả về true nếu thành công.
    func changeDirectory(to path: String) -> Bool {
        let url: URL
        if path.hasPrefix("/") {
            url = URL(fileURLWithPath: path)
        } else {
            url = currentDirectory.appendingPathComponent(path)
        }
        guard fileManager.fileExists(atPath: url.path) else { return false }
        currentDirectory = url
        return true
    }

    /// Xóa lịch sử lệnh.
    func clearHistory() {
        history.removeAll()
        lastOutput = ""
        lastError = nil
    }
}
