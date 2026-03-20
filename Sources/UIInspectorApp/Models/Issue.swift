<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
import CoreGraphics
import Foundation

enum IssueKind: String, Codable {
    case spacing
    case typography
    case contrast
    case hierarchy
    case clickability
}

struct Issue: Identifiable {
    let id = UUID()
    let kind: IssueKind
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs
import Foundation

/// User-facing issue shown in the side panel and overlay.
struct Issue: Identifiable, Hashable {
    enum Kind: String, Codable {
        case lowContrast = "Низкий контраст"
        case smallText = "Мелкий текст"
        case weakHierarchy = "Слабая визуальная иерархия"
        case inconsistentSpacing = "Неровные отступы"
        case weakCTA = "Слабый CTA"
        case lowClickability = "Некликабельный элемент"
    }

    let id: UUID
    let kind: Kind
<<<<<<< ours
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
    let severity: IssueSeverity
    let title: String
    let description: String
    let recommendation: String
<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
    let frame: CGRect
}

struct AnalysisResult {
    let elements: [UIElement]
    let issues: [Issue]
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs
    let elementID: UIElement.ID?

    init(
        id: UUID = UUID(),
        kind: Kind,
        severity: IssueSeverity,
        title: String,
        description: String,
        recommendation: String,
        elementID: UIElement.ID? = nil
    ) {
        self.id = id
        self.kind = kind
        self.severity = severity
        self.title = title
        self.description = description
        self.recommendation = recommendation
        self.elementID = elementID
    }
<<<<<<< ours
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
}
