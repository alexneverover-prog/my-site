import CoreGraphics
import Foundation

enum IssueKind: String, Codable {
    case spacing
    case typography
    case contrast
    case hierarchy
    case clickability
}

struct Issue: Identifiable, Hashable {
    let id: UUID
    let kind: IssueKind
    let severity: IssueSeverity
    let title: String
    let description: String
    let recommendation: String
    let frame: CGRect
    let elementID: UIElement.ID?

    init(
        id: UUID = UUID(),
        kind: IssueKind,
        severity: IssueSeverity,
        title: String,
        description: String,
        recommendation: String,
        frame: CGRect,
        elementID: UIElement.ID? = nil
    ) {
        self.id = id
        self.kind = kind
        self.severity = severity
        self.title = title
        self.description = description
        self.recommendation = recommendation
        self.frame = frame
        self.elementID = elementID
    }
}

struct AnalysisResult {
    let elements: [UIElement]
    let issues: [Issue]
}
