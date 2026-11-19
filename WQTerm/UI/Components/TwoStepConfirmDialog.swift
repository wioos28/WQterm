import SwiftUI

/// TwoStepConfirmDialog: confirm 2 bước trước khi thao tác nguy hiểm (PRD Nguyên tắc 5 & Module 3).
struct TwoStepConfirmDialog: ViewModifier {
    let title: String
    let message: String
    let confirmAction: () -> Void
    @Binding var isPresented: Bool
    @State private var stepTwo = false

    func body(content: Content) -> some View {
        content
            .confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
                Button(message, role: .destructive) {
                    stepTwo = true
                }
                Button("Hủy", role: .cancel) {}
            } message: {
                Text(message)
            }
            .alert("Xác nhận lần 2", isPresented: $stepTwo) {
                Button("XÓA / GHI ĐÈ", role: .destructive, action: confirmAction)
                Button("Hủy", role: .cancel) {}
            } message: {
                Text("Hành động này không thể hoàn tác. Bạn có chắc chắn?")
            }
    }
}

extension View {
    func twoStepConfirm(title: String, message: String, isPresented: Binding<Bool>, confirmAction: @escaping () -> Void) -> some View {
        modifier(TwoStepConfirmDialog(title: title, message: message, confirmAction: confirmAction, isPresented: isPresented))
    }
}
