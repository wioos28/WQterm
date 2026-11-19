# WQTerm — Hướng dẫn tạo Xcode project (trên macOS)

Môi trường scaffold hiện tại (Linux) chỉ chứa mã nguồn Swift + cấu hình. File **WQTerm.xcodeproj** phải được tạo trên **macOS với Xcode** vì `.pbxproj` là định dạng riêng của Apple và không thể sinh/check chính xác trên Linux.

## Bước 1: Tạo Xcode project
1. Mở Xcode → **File → New → Project → App** (iOS).
2. Product Name: `WQTerm`
3. Bundle Identifier: `com.wqterm.app`
4. Interface: **SwiftUI**, Language: **Swift**
5. Deployment Target: **iOS 26.0** (hỗ trợ iOS 26.0–27.3 Beta 1 theo PRD)
6. Lưu vào thư mục `/workspaces/WQterm` (tạo thư mục `WQTerm.xcodeproj`).

## Bước 2: Thêm toàn bộ mã nguồn đã scaffold
Kéo các thư mục sau vào Xcode project (hãy chọn "Copy items if needed" = OFF vì file đã nằm trong repo):
- `WQTerm/App/`
- `WQTerm/Core/` (Shell, Exploit, Backup, Runtimes, AICLI, Preview, Pairing, Security, Automation)
- `WQTerm/UI/` (Terminal, Sandbox, Backup, AICLI, Preview, Settings, Components)
- `WQTerm/Resources/`
- `WQTerm/Info.plist`, `WQTerm/Localizable.strings`, `WQTerm/LICENSE`

## Bước 3: Cấu hình Signing & Capabilities (BẮT BUỘC)
Trong Xcode → Target WQTerm → **Signing & Capabilities**:
1. Bật **App Groups** → thêm `group.com.wqterm.app` (tự sinh `WQTerm.entitlements`).
   - Giải thích (PRD 7.1): App Group bắt buộc để `worse_query` hoạt động. Người dùng phải ký với entitlement này qua SideStore/AltStore (KHÔNG dùng Sideloadly).
2. Bật **Background Modes** → chọn **Processing** (UIBackgroundModes processing).
3. Kiểm tra `get-task-allow = true` (cần cho StikDebug bật JIT).

File `WQTerm/WQTerm.entitlements` đã được scaffold sẵn (xem nội dung), hãy xác nhận Xcode sử dụng nó.

## Bước 4: Thêm Info.plist rights
Xác nhận `Info.plist` có các key theo PRD 7.2:
- `NSFaceIDUsageDescription`
- `NSLocalNetworkUsageDescription`
- `NSBonjourServices` → `_remotepairing-pairable-host._tcp`
- `UIApplicationSupportsIndirectInputEvents = true`
- `UIFileSharingEnabled = true`
- `LSSupportsOpeningDocumentsInPlace = true`
- `UIBackgroundModes = ["processing"]`

## Bước 5: Build và xuất IPA không ký (CI)
Sử dụng `.github/workflows/build.yml` (đã scaffold). Xcode command:
```
xcodebuild -project WQTerm.xcodeproj -scheme WQTerm -configuration Release \
  -sdk iphoneos -destination generic/platform=iOS \
  -archivePath build/WQTerm.xcarchive \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO archive
```
Sau đó gói `Payload/WQTerm.app` thành `WQTerm.ipa`.

## Bước 6: Sideload
- Import IPA vào SideStore / AltStore (không dùng Sideloadly).
- Ký với App Group entitlement `group.com.wqterm.app`.
- Cài và mở app, làm theo onboarding.

## Ghi hạn chế
- Swift không có sẵn trên máy scaffold Linux → chưa biên dịch kiểm thử locally.
- Các hàm private iOS (ví dụ `sandbox_extension_issue_file`) được đánh dấu stub; sẽ triển khai đầy đủ khi build trên Xcode SDK iOS.
