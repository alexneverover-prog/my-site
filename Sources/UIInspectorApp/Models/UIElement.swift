import CoreGraphics
import Foundation

enum UIElementKind: String, Codable {
    case text
    case button
    case card
    case image
    case unknown
}

struct UIElement: Identifiable, Hashable {
    let id: UUID
    let kind: UIElementKind
    let frame: CGRect
    let text: String?
    let confidence: Double

    init(
        id: UUID = UUID(),
        kind: UIElementKind,
        frame: CGRect,
        text: String? = nil,
        confidence: Double = 0
    ) {
        self.id = id
        self.kind = kind
        self.frame = frame
        self.text = text
        self.confidence = confidence
    }
}
