import Foundation

/// Adapter cho OpenAI Codex CLI (PRD Module 4: @openai/codex).
final class CodexAdapter: AICLIAdapter {
    let toolName = "codex"
    let binaryRelativePath = "Resources/node_modules/.bin/codex"

    func apiKey() -> String? {
        try? KeychainService.shared.read(key: "WQTerm.AIKey.Codex").flatMap { String(data: $0, encoding: .utf8) }
    }

    func storeAPIKey(_ key: String) throws {
        try KeychainService.shared.write(key: "WQTerm.AIKey.Codex", data: Data(key.utf8))
    }

    func run(_ arguments: [String], env: [String: String]) -> (output: String, error: String?) {
        guard let key = apiKey() else {
            return ("", "Chưa cấu hình API key Codex trong Settings › AI.")
        }
        var fullEnv = env
        fullEnv["OPENAI_API_KEY"] = key
        let cmd = [binaryRelativePath] + arguments
        return ("[stub] codex \(cmd.joined(separator: " "))", nil)
    }
}
