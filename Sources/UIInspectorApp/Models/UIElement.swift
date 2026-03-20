<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
import CoreGraphics
import Foundation

enum UIElementKind: String, Codable {
    case text
    case button
    case card
    case image
    case unknown
}

struct UIElement: Identifiable {
    let id = UUID()
    let kind: UIElementKind
    let frame: CGRect
    let text: String?
    let confidence: Double
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs
import Foundation

/// Simplified UI block detected from the screenshot.
struct UIElement: Identifiable, Hashable {
    enum Kind: String, Codable, CaseIterable {
        case text
        case button
        case card
        case image
    }

    let id: UUID
    let frame: CGRect
    let kind: Kind
    let text: String?
    let fontSize: CGFloat?
    let lineHeight: CGFloat?
    let foregroundLuminance: CGFloat?
    let backgroundLuminance: CGFloat?
    let clickableScore: CGFloat?

    init(
        id: UUID = UUID(),
        frame: CGRect,
        kind: Kind,
        text: String? = nil,
        fontSize: CGFloat? = nil,
        lineHeight: CGFloat? = nil,
        foregroundLuminance: CGFloat? = nil,
        backgroundLuminance: CGFloat? = nil,
        clickableScore: CGFloat? = nil
    ) {
        self.id = id
        self.frame = frame
        self.kind = kind
        self.text = text
        self.fontSize = fontSize
        self.lineHeight = lineHeight
        self.foregroundLuminance = foregroundLuminance
        self.backgroundLuminance = backgroundLuminance
        self.clickableScore = clickableScore
    }
<<<<<<< ours
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
}
