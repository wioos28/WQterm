# WQTerm v${{ github.run_number }}

## Tính năng đang có (Ổn định)
- Terminal Core (fork a-Shell 2.3.2)
- Sandbox Escape (worse_query) trên iOS hỗ trợ
- Backup Engine write-ahead
- AI CLI: Gemini, Claude, Codex
- Bàn phím terminal (KeyboardAccessoryView)
- UI & Security: 5 tab, onboarding, SafeMode, Face ID, Audit log
- Preview: QuickLook, Plist, SQLite, Hex, ZIP
- Pairing & JIT (StikDebug)
- AI Assistant: NL2Cmd, Error Explainer, Chat
- Automation & UX: Snippets, File Browser, Storage Inspector, Recipes
- Beta Feedback: báo cáo lỗi UI/UX, Crash, Logic + xuất file .zip

## Tính năng đang phát triển (Có thể lỗi, sẽ vá sau)
- Ghi MobileGestalt + /var/containers/Data/System
- OpenCode (Bun runtime)
- LiveContainer pairing fix
- Script Generator, Sensitive Scanner, Semantic Search
- Workflow Automation, Container Diff, Safe Share

## Yêu cầu hệ thống
- iOS 26.0–27.3 Beta 1 (hỗ trợ đầy đủ: 27.0–27.2.1)
- App Group entitlement: `group.com.wqterm.app`
- Ký bằng SideStore/AltStore (KHÔNG dùng Sideloadly)

## Cài đặt
1. Tải file `WQTerm.ipa` bên dưới.
2. Import vào SideStore/AltStore.
3. Ký với App Group entitlement (xem README).
4. Cài và mở app, làm theo onboarding.

## Cảnh báo bảo mật
⚠️ WQTerm đọc/ghi được dữ liệu của các ứng dụng khác. Chỉ dùng trên thiết bị cá nhân hoặc có sự cho phép bằng văn bản.
⚠️ Sử dụng cho mục đích truy cập dữ liệu người khác có thể vi phạm pháp luật.
⚠️ Apple có thể vá `worse_query` bất kỳ lúc nào — đóng băng iOS ở phiên bản hỗ trợ.

## Pairing & JIT
- Pairing: iOS 27+ tự động, iOS 18–26 cần máy tính.
- JIT: tùy chọn, cần StikDebug + LocalDevVPN.

## License
GPL-3.0. Source: https://github.com/wioos28/WQterm
