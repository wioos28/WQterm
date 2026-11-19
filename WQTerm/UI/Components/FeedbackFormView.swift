import SwiftUI

/// Form báo cáo lỗi: chọn loại, nhập mô tả, chụp ảnh màn hình, xuất file.
struct FeedbackFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: FeedbackType = .uiux
    @State private var description: String = ""
    @State private var isSending = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Loại lỗi")) {
                    Picker("Chọn loại", selection: $selectedType) {
                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Mô tả chi tiết")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 150)
                }

                Section {
                    Button(action: submit) {
                        HStack {
                            if isSending {
                                ProgressView().scaleEffect(0.8)
                            }
                            Text("Gửi báo cáo lỗi")
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(description.isEmpty || isSending)
                }
            }
            .navigationTitle("Báo cáo lỗi / Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") { dismiss() }
                }
            }
            .alert("Thông báo", isPresented: $showAlert) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func submit() {
        let report = FeedbackReport(type: selectedType, description: description)
        // Chụp ảnh màn hình hiện tại
        let screenshot = UIApplication.shared.windows.first { $0.isKeyWindow }?
            .rootViewController?.view?.takeScreenshot()
        let saved = FeedbackManager.shared.saveReport(report, screenshot: screenshot)

        if saved != nil {
            // Xuất file zip ngay cho người dùng share
            if let zipURL = FeedbackManager.shared.exportAllReportsZip() {
                if let rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
                    .rootViewController {
                    FeedbackManager.shared.presentShare(from: rootVC, fileURL: zipURL)
                }
            }
            alertMessage = "Đã tạo file báo cáo lỗi. Hãy chọn cách gửi (Zalo, Telegram, Email…) và gửi lại cho team dev."
            showAlert = true
        } else {
            alertMessage = "Không lưu được báo cáo lỗi. Vui lòng thử lại."
            showAlert = true
        }
    }
}

// MARK: - Screenshot helper

extension UIView {
    func takeScreenshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
