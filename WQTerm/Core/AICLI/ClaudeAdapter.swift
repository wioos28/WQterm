import Foundation

/// Adapter cho Anthropic Claude Code CLI (PRD Module 4: @anthropic-ai/claude-code).
final class ClaudeAdapter: AICLIAdapter {
    let toolName = "claude"
    let binaryRelativePath = "Resources/node_modules/.bin/claude"

    func apiKey() -> String? {
        try? KeychainService.shared.read(key: "WQTerm.AIKey.Claude").flatMap { String(data: $0, encoding: .utf8) }
    }

    func storeAPIKey(_ key: String) throws {
        try KeychainService.shared.write(key: "WQTerm.AIKey.Claude", data: Data(key.utf8))
    }

    func run(_ arguments: [String], env: [String: String]) -> (output: String, error: String?) {
        guard let key = apiKey() else {
            return ("", "Chưa cấu hình API key Claude trong Settings › AI.")
        }
        var fullEnv = env
        fullEnv["ANTHROPIC_API_KEY"] = key
        let cmd = [binaryRelativePath] + arguments
        return ("[stub] claude \(cmd.joined(separator: " "))", nil)
    }
}
