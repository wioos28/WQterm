import SwiftUI

/// KeyboardAccessoryView: 2 hàng nút terminal (PRD Module 5).
struct KeyboardAccessoryView: View {
    var onKey: (String) -> Void

    /// Hàng 1 — Điều hướng: ESC, TAB, Ctrl, Alt, ↑↓←→, Home, End, PgUp, PgDn
    let row1: [[String]] = [
        ["ESC", "TAB", "Ctrl", "Alt"],
        ["↑", "↓", "←", "→"],
        ["Home", "End", "PgUp", "PgDn"]
    ]

    /// Hàng 2 — Clipboard & tiện ích: Copy, Paste, Select All, Clear, Kill, Menu
    let row2: [[String]] = [
        ["Copy", "Paste", "Select All", "Clear"],
        ["Kill", "Menu"]
    ]

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 4) {
                ForEach(Array(row1.enumerated()), id: \.offset) { _, keys in
                    HStack(spacing: 4) {
                        ForEach(keys, id: \.self) { key in
                            AccessoryKey(title: key) { onKey(key) }
                        }
                    }
                }
                ForEach(Array(row2.enumerated()), id: \.offset) { _, keys in
                    HStack(spacing: 4) {
                        ForEach(keys, id: \.self) { key in
                            AccessoryKey(title: key) { onKey(key) }
                        }
                    }
                }
            }
            .padding(6)
        }
        .frame(maxHeight: 200) // 44pt/hàng x 5 hàng + padding
    }
}

struct AccessoryKey: View {
    let title: String
    let action: () -> Void
    @State private var active = false

    var body: some View {
        Button(action: {
            active = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { active = false }
        }) {
            Text(title)
                .font(.caption2).bold()
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(active ? Color.blue.opacity(0.3) : Color.gray.opacity(0.15))
                .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
