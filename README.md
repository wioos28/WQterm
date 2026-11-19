# WQTerm

Terminal mã nguồn mở dành cho iOS (không jailbreak), khai thác lỗ hổng `worse_query` để truy cập container của các ứng dụng khác trên thiết bị. Tích hợp sẵn AI CLI (Gemini, Claude, Codex) chạy offline, hệ thống backup write-ahead bảo vệ dữ liệu, trình preview đa định dạng (plist, SQLite, hex, ảnh, PDF…), và hệ thống pairing/JIT tích hợp. Build tự động qua GitHub Actions, xuất file `.ipa` không ký để sideload qua SideStore/AltStore/LiveContainer với App Group entitlement. Hỗ trợ iOS 26.0–27.3 Beta 1.

## Trạng thái kho này (scaffold M0)
Kho chứa hiện đang ở **giai đoạn M0 (thiết lập môi trường)**: toàn bộ cấu trúc thư mục, mã nguồn Swift cho các module, `Info.plist`, `WQTerm.entitlements`, GitHub Actions workflow, tài liệu và bản quyền đã được tạo sẵn. File `WQTerm.xcodeproj` **chưa được tạo** (cần macOS + Xcode — xem `PROJECT_SETUP.md`).

## Cấu trúc thư mục
```
WQTerm/
├── .github/workflows/build.yml          # CI build IPA không ký
├── WQTerm.xcodeproj                     # (tạo trên macOS theo PROJECT_SETUP.md)
├── WQTerm/
│   ├── App/                             # Entry point, AppDelegate
│   ├── Core/
│   │   ├── Shell/                       # ShellSession, CommandExecutor
│   │   ├── Exploit/                     # IOSCompatibility, WorseQuery, SandboxMounter
│   │   ├── Backup/                      # Snapshot, ContainerArchiver, Restore, SelfBackup, Encryption
│   │   ├── Runtimes/                    # NodeRuntime, PythonRuntime, RuntimeManager
│   │   ├── AICLI/                       # Gemini, Claude, Codex adapters
│   │   ├── Preview/                     # QuickLook, PlistViewer, SQLiteViewer, HexViewer, ZipBrowser
│   │   ├── Pairing/                     # PairingManager, JITManager
│   │   ├── Security/                    # AuditLogger, FaceIDLock, SensitiveAppGuard, SafeMode
│   │   └── Automation/                  # SnippetManager, WorkflowEngine
│   ├── UI/
│   │   ├── Terminal/                    # TerminalView, KeyboardAccessoryView
│   │   ├── Sandbox/                     # SandboxListView, ContainerBrowserView
│   │   ├── Backup/                      # BackupListView, RestoreConfirmView
│   │   ├── AICLI/                       # AICLISettingsView, APIKeyInputView, ChatView
│   │   ├── Preview/                     # PreviewContainerView, renderers
│   │   ├── Settings/                    # SettingsView, SecuritySettings, PairingSettings, JITSettings
│   │   └── Components/                  # WarningBanner, TwoStepConfirmDialog, BlurSensitiveView
│   ├── Resources/                       # ios_system, node-ios-arm64, node_modules, Recipes
│   ├── Info.plist
│   ├── WQTerm.entitlements              # App Group group.com.wqterm.app
│   └── Localizable.strings              # Tiếng Việt
├── LICENSE                              # GPL-3.0
├── LICENSES/                            # Third-party licenses
├── README.md
├── CHANGELOG.md
└── PROJECT_SETUP.md                     # Hướng dẫn tạo Xcode project
```

## Nguyên tắc bất biến (PRD)
1. Không server, không backend, không VPS — hoạt động offline.
2. Không .deb / apt / dpkg, không jailbreak, không root.
3. Mọi ghi vào container app khác phải có backup write-ahead trước.
4. Mã nguồn mở, minh bạch, có cảnh báo bảo mật rõ ràng.
5. Không tự động chạy lệnh nguy hiểm — luôn có dry-run hoặc confirm 2 bước.
6. Không gửi dữ liệu người dùng ra ngoài trừ khi người dùng chủ động yêu cầu (AI CLI call).

## Cảnh báo bảo mật
⚠️ WQTerm đọc/ghi được dữ liệu của các ứng dụng khác. Chỉ dùng trên thiết bị cá nhân hoặc có sự cho phép bằng văn bản.
⚠️ Sử dụng cho mục đích truy cập dữ liệu người khác có thể vi phạm pháp luật (Điều 289 Bộ luật Hình sự 2015).
⚠️ Apple có thể vá `worse_query` bất kỳ lúc nào — đóng băng iOS ở phiên bản hỗ trợ.

## License
GPL-3.0 (mã chính, do fork từ a-Shell). Xem `LICENSE` và `LICENSES/` cho third-party.

