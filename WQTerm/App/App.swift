import SwiftUI
import UIKit

@main
struct WQTermApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var compatibility = IOSCompatibility.shared
    @StateObject private var security = SecurityManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if security.isLocked {
                    LockPlaceholderView()
                } else if !OnboardingStorage.hasAgreed {
                    OnboardingView { OnboardingStorage.markAgreed() }
                } else {
                    ZStack {
                        TabView {
                            TerminalView()
                                .tabItem { Label("Terminal", systemImage: "terminal") }
                            Text("Sandbox (M2)")
                                .tabItem { Label("Sandbox", systemImage: "externaldrive") }
                            Text("Backup (M3)")
                                .tabItem { Label("Backup", systemImage: "externaldrive") }
                            Text("AI (M4/M9)")
                                .tabItem { Label("AI", systemImage: "sparkles") }
                            Text("Cài đặt (M6)")
                                .tabItem { Label("Cài đặt", systemImage: "gear") }
                        }
                        WarningBanner(message: compatibility.bannerMessage,
                                      type: compatibility.isRestrictedMode ? .restricted : .warning)
                        .padding(.top, 8)
                        .frame(maxHeight: .infinity, alignment: .top)
                        // Nút feedback nổi ở góc phải dưới màn hình
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                BetaFeedbackIntegration.makeFloatingButton()
                                    .padding(20)
                            }
                        }
                    }
                }
            }
            .onAppear {
                compatibility.recheckOnForeground()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                compatibility.recheckOnForeground()
            }
        }
    }
}

// MARK: - Onboarding storage (UserDefaults)

enum OnboardingStorage {
    private static let key = "WQTerm.Onboarding.Agreed"
    static var hasAgreed: Bool {
        UserDefaults.standard.bool(forKey: key)
    }
    static func markAgreed() {
        UserDefaults.standard.set(true, forKey: key)
    }
}

// MARK: - Placeholder views (tạm thời cho các module chưa build UI chi tiết)

struct LockPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("WQTerm đang bị khóa")
                .font(.headline)
            Text("Vui lòng xác thực Face ID để mở khóa ứng dụng.")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct OnboardingView: View {
    let onAgree: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("WQTerm — Cảnh bảo mật").font(.title).bold()
            Text("WQTerm đọc/ghi được dữ liệu của các ứng dụng khác trên thiết bị. Chỉ dùng trên thiết bị cá nhân hoặc có sự cho phép bằng văn bản. Truy cập dữ liệu người khác có thể vi phạm pháp luật (Điều 289 Bộ luật Hình sự 2015).")
                .multilineTextAlignment(.center).foregroundColor(.red)
            Text("Apple có thể vá worse_query bất kỳ lúc nào — đóng băng iOS ở phiên bản hỗ trợ.")
                .foregroundColor(.secondary)
            Button("Tôi đồng ý và tiếp tục") { onAgree() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
