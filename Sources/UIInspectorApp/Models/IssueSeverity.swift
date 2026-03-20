<<<<<<< ours
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
            return Color.red
        }
    }

    var overlayColor: Color {
        switch self {
        case .warning:
            return Color.yellow
        case .critical:
            return Color.red
        }
    }
}
=======
import Foundation
#if os(macOS)
import SwiftUI
#endif

/// Severity used to style issue badges and overlay borders.
enum IssueSeverity: String, Codable, CaseIterable, Identifiable, Hashable {
    case warning
    case critical

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warning: "Warning"
        case .critical: "Critical"
        }
    }
}

#if os(macOS)
extension IssueSeverity {
    var color: Color {
        switch self {
        case .warning: .orange
        case .critical: .red
        }
    }
}
#endif
>>>>>>> theirs
