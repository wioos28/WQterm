import SwiftUI

/// Blur sensitive: che nội dung đến khi chạm (PRD Module 7.5 Bảo mật).
struct BlurSensitiveView<Content: View>: View {
    let content: Content
    @State private var revealed = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
            if revealed {
                content
            } else {
                content
                    .blur(radius: 10)
                    .disabled(true)
                    .overlay(
                        Button("Xem nội dung nhạy cảm") { revealed = true }
                            .buttonStyle(.bordered)
                            .padding(4)
                    )
            }
        }
    }
}
