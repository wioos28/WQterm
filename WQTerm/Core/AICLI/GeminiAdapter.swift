import Foundation

/// Adapter cho Google Gemini CLI (PRD Module 4: @google/gemini-cli).
final class GeminiAdapter: AICLIAdapter {
    let toolName = "gemini"
    let binaryRelativePath = "Resources/node_modules/.bin/gemini"

    func apiKey() -> String? {
        try? KeychainService.shared.read(key: "WQTerm.AIKey.Gemini").flatMap { String(data: $0, encoding: .utf8) }
    }

    func storeAPIKey(_ key: String) throws {
        try KeychainService.shared.write(key: "WQTerm.AIKey.Gemini", data: Data(key.utf8))
    }

    func run(_ arguments: [String], env: [String: String]) -> (output: String, error: String?) {
        guard let key = apiKey() else {
            return ("", "Chưa cấu hình API key Gemini trong Settings › AI.")
        }
        var fullEnv = env
        fullEnv["GEMINI_API_KEY"] = key
        // Thực thi qua Node runtime (xem NodeRuntime). Stub ở đây.
        let cmd = [binaryRelativePath] + arguments
        return ("[stub] gemini \(cmd.joined(separator: " "))", nil)
    }
}
