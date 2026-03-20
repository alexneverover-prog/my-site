import SwiftUI

enum IssueSeverity: String, CaseIterable, Codable {
    case warning
    case critical

    var title: String {
        switch self {
        case .warning:
            return L10n.warning
        case .critical:
            return L10n.critical
        }
    }

    var color: Color {
        switch self {
        case .warning:
            return Color.orange
        case .critical:
            return Color(red: 0.87, green: 0.29, blue: 0.26)
        }
    }

    var overlayColor: Color {
        switch self {
        case .warning:
            return Color(red: 1.0, green: 0.77, blue: 0.31)
        case .critical:
            return Color(red: 1.0, green: 0.45, blue: 0.4)
        }
    }
}
