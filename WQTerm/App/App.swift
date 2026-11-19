import SwiftUI

@main
struct WQTermApp: App {
    @StateObject private var compatibility = IOSCompatibility.shared
    @StateObject private var security = SecurityManager.shared
    @State private var showOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if security.isLocked {
                    LockView()
                } else if !OnboardingStorage.hasAgreed {
                    OnboardingView { showOnboarding = false }
                } else {
                    ZStack {
                        MainTabView()
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

// MARK: - Placeholder views (to be replaced by real UI modules)

struct MainTabView: View {
    var body: some View {
        TabView {
            TerminalView().tabItem { Label("Terminal", systemImage: "terminal") }
            SandboxListView().tabItem { Label("Sandbox", systemImage: "externaldrive") }
            BackupListView().tabItem { Label("Backup", systemImage: "externaldrive") }
            AICLISettingsView().tabItem { Label("AI", systemImage: "sparkles") }
            SettingsView().tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

struct TerminalView: View { var body: some View { Text("Terminal Core (M1)") } }
struct SandboxListView: View { var body: some View { Text("Sandbox List (M2/M6)") } }
struct BackupListView: View { var body: some View { Text("Backup List (M3)") } }
struct AICLISettingsView: View { var body: some View { Text("AI CLI Settings (M4/M9)") } }
struct SettingsView: View { var body: some View { Text("Settings (M6)") } }
struct LockView: View { var body: some View { Text("Face ID Lock (M6)") } }
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
