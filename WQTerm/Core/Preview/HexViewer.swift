import Foundation

/// Hex viewer: hex + ASCII + magic bytes detection (PRD Module 7.2).
final class HexViewer {
    static let shared = HexViewer()
    private init() {}

    /// Phát hiện định dạng qua magic bytes (stub).
    func detectFormat(url: URL) -> String {
        guard let data = try? Data(contentsOf: url), data.count >= 4 else { return "unknown" }
        let bytes = [UInt8](data.prefix(4))
        if bytes == [0x25, 0x50, 0x44, 0x46] { return "PDF (%PDF)" }
        if bytes == [0x50, 0x4B, 0x03, 0x04] { return "ZIP (PK)" }
        if bytes == [0x7F, 0x45, 0x4C, 0x46] { return "ELF" }
        if bytes == [0xCA, 0xFE, 0xBA, 0xBE] { return "Mach-O (classic)" }
        if bytes == [0xFE, 0xED, 0xFA, 0xCE] || bytes == [0xFE, 0xED, 0xFA, 0xCF] { return "Mach-O" }
        if bytes == [0x25, 0x21, 0x50, 0x53] { return "PostScript" }
        return "text/binary"
    }

    func hexDump(url: URL, limit: Int = 4096) -> String {
        guard let data = try? Data(contentsOf: url) else { return "Không đọc được file" }
        let sample = data.prefix(limit)
        var lines: [String] = []
        for i in stride(from: 0, to: sample.count, by: 16) {
            let chunk = sample.subdata(in: i..<min(i+16, sample.count))
            let hex = chunk.map { String(format: "%02x", $0) }.joined(separator: " ")
            let ascii = chunk.map { byte in
                (32...126).contains(byte) ? String(UnicodeScalar(byte)) : "."
            }.joined()
            lines.append(String(format: "%08x  %-48s  %@", i, hex, ascii))
        }
        return lines.joined(separator: "\n")
    }
}
