import SwiftUI

/// Nút "Báo cáo lỗi / Feedback" nổi ở góc màn hình (hoặc đặt trong Settings).
struct FeedbackButton: View {
    @State private var showForm = false

    var body: some View {
        Button(action: { showForm = true }) {
            Image(systemName: "exclamationmark.bubble.fill")
                .font(.title2)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.red)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .sheet(isPresented: $showForm) {
            FeedbackFormView()
        }
        .accessibilityLabel("Báo cáo lỗi / Feedback")
    }
}
