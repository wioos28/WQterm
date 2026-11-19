import Foundation

/// ZIP browser: liệt kê nội dung không cần giải nén (PRD Module 7.2).
final class ZipBrowser {
    static let shared = ZipBrowser()
    private let fileManager = FileManager.default

    private init() {}

    struct ZipEntry {
        let name: String
        let size: UInt64
        let isDirectory: Bool
    }

    /// Liệt kê nội dung ZIP bằng cách đọc End of Central Directory (EOCD) record.
    /// Trả về danh sách các entry trong file ZIP.
    func listEntries(url: URL) -> [ZipEntry] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        return parseZipEntries(data: data)
    }

    private func parseZipEntries(data: Data) -> [ZipEntry] {
        // Đọc EOCD (End of Central Directory) record từ cuối file
        // EOCD signature: 0x06054b50 (PK..)
        let eocdSignature: [UInt8] = [0x50, 0x4B, 0x05, 0x06]
        var entries: [ZipEntry] = []

        // Tìm EOCD từ cuối file (tối đa 65535 bytes)
        let searchRange = min(data.count, 65535)
        var eocdOffset: Int? = nil

        for i in stride(from: data.count - searchRange, to: data.count - 4, by: 1) {
            var match = true
            for j in 0..<4 {
                if data[i + j] != eocdSignature[j] {
                    match = false
                    break
                }
            }
            if match {
                eocdOffset = i
                break
            }
        }

        guard let eocdPos = eocdOffset else { return entries }

        // EOCD structure:
        // Offset 0: Signature (4 bytes)
        // Offset 4: Disk number (2 bytes)
        // Offset 6: Start disk number (2 bytes)
        // Offset 8: Number of entries on this disk (2 bytes)
        // Offset 10: Total number of entries (2 bytes)
        // Offset 12: Size of central directory (4 bytes)
        // Offset 16: Offset of central directory (4 bytes)
        // Offset 20: Comment length (2 bytes)

        let totalEntriesOffset = eocdPos + 10
        let totalEntries = Int(data[totalEntriesOffset]) | (Int(data[totalEntriesOffset + 1]) << 8)

        let cdSizeOffset = eocdPos + 12
        let cdSize = Int(data[cdSizeOffset]) | (Int(data[cdSizeOffset + 1]) << 8) |
                     (Int(data[cdSizeOffset + 2]) << 16) | (Int(data[cdSizeOffset + 3]) << 24)

        let cdOffsetOffset = eocdPos + 16
        let cdOffset = Int(data[cdOffsetOffset]) | (Int(data[cdOffsetOffset + 1]) << 8) |
                       (Int(data[cdOffsetOffset + 2]) << 16) | (Int(data[cdOffsetOffset + 3]) << 24)

        // Central Directory File Header structure:
        // Offset 0: Signature (4 bytes) = 0x02014b50
        // Offset 4: Version made by (2 bytes)
        // Offset 6: Version needed (2 bytes)
        // Offset 8: Flags (2 bytes)
        // Offset 10: Compression method (2 bytes)
        // Offset 12: Last mod time (2 bytes)
        // Offset 14: Last mod date (2 bytes)
        // Offset 16: CRC-32 (4 bytes)
        // Offset 20: Compressed size (4 bytes)
        // Offset 24: Uncompressed size (4 bytes)
        // Offset 28: File name length (2 bytes)
        // Offset 30: Extra field length (2 bytes)
        // Offset 32: File comment length (2 bytes)
        // Offset 34: Disk number start (2 bytes)
        // Offset 36: Internal file attributes (2 bytes)
        // Offset 38: External file attributes (4 bytes)
        // Offset 42: Relative offset of local header (4 bytes)
        // Offset 46: File name (variable)

        let cdEnd = cdOffset + cdSize
        var pos = cdOffset

        for _ in 0..<totalEntries {
            guard pos + 46 <= data.count else { break }
            // Kiểm tra signature
            let sig = Int(data[pos]) | (Int(data[pos + 1]) << 8) |
                      (Int(data[pos + 2]) << 16) | (Int(data[pos + 3]) << 24)
            guard sig == 0x02014b50 else { break }

            let nameLenOffset = pos + 28
            let nameLen = Int(data[nameLenOffset]) | (Int(data[nameLenOffset + 1]) << 8)

            let extraLenOffset = pos + 30
            let extraLen = Int(data[extraLenOffset]) | (Int(data[extraLenOffset + 1]) << 8)

            let sizeOffset = pos + 24
            let uncompressedSize = Int(data[sizeOffset]) | (Int(data[sizeOffset + 1]) << 8) |
                                   (Int(data[sizeOffset + 2]) << 16) | (Int(data[sizeOffset + 3]) << 24)

            let nameStart = pos + 46
            let nameEnd = nameStart + nameLen
            guard nameEnd <= data.count else { break }

            let nameBytes = data.subdata(in: nameStart..<nameEnd)
            let name = String(data: nameBytes, encoding: .utf8) ?? ""

            let isDirectory = name.hasSuffix("/")

            entries.append(ZipEntry(name: name, size: UInt64(uncompressedSize), isDirectory: isDirectory))

            pos = nameEnd + nameLen + extraLen
        }

        return entries
    }
}
