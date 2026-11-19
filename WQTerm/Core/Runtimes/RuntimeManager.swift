import Foundation

/// Quản lý các runtime nhúng (Node.js, Python) (PRD Module 4).
enum Runtime: String, CaseIterable {
    case node = "node"
    case python = "python3"
}

final class RuntimeManager: ObservableObject {
    static let shared = RuntimeManager()
    @Published var availableRuntimes: [Runtime: Bool] = [:]

    private let nodeRuntime = NodeRuntime()
    private let pythonRuntime = PythonRuntime()

    private init() {
        availableRuntimes[.node] = nodeRuntime.isAvailable
        availableRuntimes[.python] = pythonRuntime.isAvailable
    }

    func binaryURL(for runtime: Runtime) -> URL? {
        switch runtime {
        case .node: return nodeRuntime.binaryURL
        case .python: return pythonRuntime.binaryURL
        }
    }
}

final class NodeRuntime {
    let isAvailable: Bool
    let binaryURL: URL?
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(".terminal/RuntimeManager/node-ios-arm64/bin/node", isDirectory: false)
        self.binaryURL = url
        self.isAvailable = FileManager.default.fileExists(atPath: url.path)
    }
}

final class PythonRuntime {
    let isAvailable: Bool
    let binaryURL: URL?
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(".terminal/RuntimeManager/python-ios/bin/python3", isDirectory: false)
        self.binaryURL = url
        self.isAvailable = FileManager.default.fileExists(atPath: url.path)
    }
}
