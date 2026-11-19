import SwiftUI

/// WarningBanner phản ánh trạng thái worse_query (PRD Module 6 UI Components).
struct WarningBanner: View {
    let message: String
    let type: BannerType

    enum BannerType {
        case info, warning, restricted
        var color: Color {
            switch self { case .info: return .blue; case .warning: return .orange; case .restricted: return .red }
        }
        var icon: String {
            switch self { case .info: return "info.circle"; case .warning: return "exclamationmark.triangle"; case .restricted: return "exclamationmark.octagon" }
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: type.icon).foregroundColor(type.color)
            Text(message).font(.caption).foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(type.color.opacity(0.12))
        .cornerRadius(8)
    }
}
