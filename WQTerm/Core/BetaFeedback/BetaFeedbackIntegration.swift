import SwiftUI

/// Tích hợp BetaFeedback vào ứng dụng: thêm nút feedback vào Settings và các màn hình chính.
/// Sử dụng: đặt `FeedbackButton()` vào góc màn hình hoặc trong SettingsView.
struct BetaFeedbackIntegration {
    /// Thêm nút feedback nổi (floating) vào root view.
    static func makeFloatingButton() -> some View {
        FeedbackButton()
    }
}
