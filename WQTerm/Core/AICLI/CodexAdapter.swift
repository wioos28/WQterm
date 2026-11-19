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
        // Thực thi qua Node.js runtime
        let nodeRuntime = RuntimeManager.shared.binaryURL(for: .node)
        guard let nodePath = nodeRuntime?.path else {
            return ("", "Node.js runtime không tìm thấy. Vui lòng cài đặt node-ios-arm64 trong Resources.")
        }
        let cliPath = Bundle.main.bundleURL.appendingPathComponent(binaryRelativePath).path
        let process = Process()
        process.executableURL = URL(fileURLWithPath: nodePath)
        process.arguments = [cliPath] + arguments
        process.environment = fullEnv

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
            process.waitUntilExit()
            let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: stdoutData, encoding: .utf8) ?? ""
            let errorOutput = String(data: stderrData, encoding: .utf8) ?? ""
            if process.terminationStatus == 0 {
                return (output, errorOutput.isEmpty ? nil : errorOutput)
            } else {
                return (output, errorOutput.isEmpty ? "Codex CLI thoát với mã \(process.terminationStatus)" : errorOutput)
            }
        } catch {
            return ("", "Không thể thực thi Codex CLI: \(error.localizedDescription)")
        }
    }
}
