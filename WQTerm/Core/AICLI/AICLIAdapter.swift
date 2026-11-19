import Foundation

/// Giao diện chung cho các adapter AI CLI (PRD Module 4 & M9).
protocol AICLIAdapter {
    var toolName: String { get }
    var binaryRelativePath: String { get }
    func apiKey() -> String?
    func storeAPIKey(_ key: String) throws
    func run(_ arguments: [String], env: [String: String]) -> (output: String, error: String?)
}

/// Quản lý gọi các CLI AI (chỉ chạy khi người dùng chủ động yêu cầu — PRD Nguyên tắc 6).
final class AICLIManager {
    static let shared = AICLIManager()
    private let adapters: [String: AICLIAdapter] = [
        "gemini": GeminiAdapter(),
        "claude": ClaudeAdapter(),
        "codex": CodexAdapter()
    ]

    private init() {}

    func call(tool: String, arguments: [String], env: [String: String] = [:]) -> (output: String, error: String?) {
        guard let adapter = adapters[tool] else {
            return ("", "Không hỗ trợ công cụ AI: \(tool)")
        }
        let result = adapter.run(arguments, env: env)
        AuditLogger.shared.log(event: .aiCLICall(tool: tool))
        return result
    }
}
