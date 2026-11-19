import SwiftUI

/// Màn hình terminal chính (M1): hiển thị output, nhập lệnh, bàn phéon phụ.
struct TerminalView: View {
    @StateObject private var session = ShellSession.shared
    @State private var input: String = ""
    @State private var scrollToBottom = false

    var body: some View {
        VStack(spacing: 0) {
            // Danh sách output terminal
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(session.history, id: \.self) { cmd in
                            Text("> \(cmd)")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if !session.lastOutput.isEmpty {
                                Text(session.lastOutput)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if let error = session.lastError {
                                Text(error)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .onChange(of: session.history.count) { _ in
                    scrollToBottom = true
                }
            }

            // Ô nhập lệnh
            HStack(spacing: 8) {
                TextField("Nhập lệnh...", text: $input, onCommit: {
                    runCommand()
                })
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)

                Button("Chạy") {
                    runCommand()
                }
                .buttonStyle(.borderedProminent)
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()

            // Nút Báo cáo lỗi nổi (tùy chọn, có thể bỏ nếu đã có floating button global)
            // FeedbackButton() // đã đặt ở App.swift

            // Bàn phím phụ terminal
            KeyboardAccessoryView { key in
                handleAccessoryKey(key)
            }
        }
        .navigationTitle("Terminal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func runCommand() {
        let cmd = input
        input = ""
        session.run(cmd)
    }

    private func handleAccessoryKey(_ key: String) {
        switch key {
        case "Kill":
            session.run("^C")
        case "Clear":
            session.clearHistory()
        case "Copy":
            UIPasteboard.general.string = session.lastOutput
        case "Paste":
            if let paste = UIPasteboard.general.string {
                input += paste
            }
        case "Select All":
            input = session.history.joined(separator: "\n")
        default:
            input += key
        }
    }
}
