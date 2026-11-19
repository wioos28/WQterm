import Foundation

/// Quản lý nhiều phiên terminal (PRD Module 1: ShellSession).
final class ShellSession: ObservableObject {
    static let shared = ShellSession()
    private let executor = CommandExecutor.shared

    @Published var currentDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    @Published var history: [String] = []

    func run(_ command: String) -> (output: String, error: String?) {
        history.append(command)
        let result = executor.execute(command, in: currentDirectory)
        return result
    }

    func changeDirectory(to path: String) -> Bool {
        let url: URL
        if path.hasPrefix("/") {
            url = URL(fileURLWithPath: path)
        } else {
            url = currentDirectory.appendingPathComponent(path)
        }
        guard FileManager.default.fileExists(atPath: url.path) else { return false }
        currentDirectory = url
        return true
    }
}
