# WQTerm — CHANGELOG

## [1.0.0] — 2026-11-19 (M0 scaffold)
- Tạo cấu trúc dự án theo PRD WQTerm
- Thêm WQTerm.entitlements (App Group `group.com.wqterm.app`, get-task-allow)
- Thêm Info.plist với quyền runtime (Face ID, LocalNetwork, Bonjour pairing)
- Thêm GitHub Actions workflow build .ipa không ký
- Scaffold module: Exploit (IOSCompatibility, WorseQuery, SandboxMounter), Security (AuditLogger, SafeMode, FaceID, SensitiveAppGuard), Shell (ShellSession, CommandExecutor), Backup (Encryption, Snapshot, ContainerArchiver), AICLI (Gemini/Claude/Codex adapters), Runtimes (Node/Python RuntimeManager), Pairing (PairingManager, JITManager), Preview (QuickLook, Plist, Hex, Zip), UI Components (WarningBanner, TwoStepConfirmDialog, BlurSensitiveView, KeyboardAccessoryView)
- Thêm Localizable.strings (vi), LICENSE (GPL-3.0), CHANGELOG.md

## [Chưa có bản release]
- M1 Terminal Core (fork a-Shell 2.3.2)
- M2 Sandbox Escape worse_query đầy đủ
- M3 Backup Engine đầy đủ (restore 2 bước, self-backup .wqterm-config.zip)
- M4 AI CLI (Gemini, Claude, Codex) + Node.js arm64 build
- M5 KeyboardAccessoryView
- M6 UI & Security (5 tab, onboarding, SafeMode, FaceID, Audit log)
- M7 Preview (QuickLook, Plist, SQLite, Hex, ZIP)
- M8 Pairing & JIT (StikDebug)
- M9 AI Assistant (NL2Cmd, Error Explainer, Chat)
- M10 Automation & UX (Snippets, File Browser, Recipes)
