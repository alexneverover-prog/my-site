#if canImport(AppKit)
import AppKit
import Combine
import Foundation
import UniformTypeIdentifiers

@MainActor
final class InspectorViewModel: ObservableObject {
    @Published var screenshot: NSImage?
    @Published var issues: [Issue] = []
    @Published var elements: [UIElement] = []
    @Published var selectedIssueID: Issue.ID?
    @Published var isImporting = false
    @Published var isAnalyzing = false
    @Published var statusText = L10n.statusInitial

    private let analyzer = UIAnalyzer()

    var selectedIssue: Issue? {
        issues.first { $0.id == selectedIssueID }
    }

    var criticalCount: Int {
        issues.filter { $0.severity == .critical }.count
    }

    var warningCount: Int {
        issues.filter { $0.severity == .warning }.count
    }

    var currentScreenTitle: String {
        screenshot == nil ? L10n.currentScreenPlaceholder : L10n.currentScreenDetected
    }

    var findingsCountText: String {
        L10n.findingsCount(issues.count)
    }

    func openImporter() {
        isImporting = true
    }

    func loadImage(from url: URL) {
        guard let image = NSImage(contentsOf: url) else {
            statusText = L10n.statusInvalidImage
            return
        }

        applyLoadedImage(image, status: L10n.statusLoaded)
    }

    func pasteFromClipboard() {
        let pasteboard = NSPasteboard.general

        if let image = pasteboard.readObjects(forClasses: [NSImage.self])?.first as? NSImage {
            applyLoadedImage(image, status: L10n.statusPasted)
            return
        }

        if let image = imageFromPasteboard(pasteboard) {
            applyLoadedImage(image, status: L10n.statusPasted)
            return
        }

        statusText = pasteboard.pasteboardItems?.isEmpty == false
            ? L10n.statusClipboardUnsupported
            : L10n.statusClipboardEmpty
    }

    func analyze() {
        guard let screenshot else {
            statusText = L10n.statusNeedUpload
            return
        }

        isAnalyzing = true
        statusText = L10n.statusAnalyzing

        let result = analyzer.analyze(image: screenshot)
        elements = result.elements
        issues = result.issues
        selectedIssueID = result.issues.first?.id
        isAnalyzing = false

        if result.issues.isEmpty {
            statusText = L10n.statusNoIssues
        } else {
            statusText = L10n.statusFoundIssues(result.issues.count)
        }
    }

    func selectIssue(_ issue: Issue) {
        selectedIssueID = issue.id
    }

    private func applyLoadedImage(_ image: NSImage, status: String) {
        screenshot = image
        issues = []
        elements = []
        selectedIssueID = nil
        statusText = status
    }

    private func imageFromPasteboard(_ pasteboard: NSPasteboard) -> NSImage? {
        let directTypes: [NSPasteboard.PasteboardType] = [
            .png,
            .tiff,
            .init(UTType.jpeg.identifier),
            .init(UTType.heic.identifier),
            .init(UTType.gif.identifier)
        ]

        for type in directTypes {
            if let data = pasteboard.data(forType: type), let image = NSImage(data: data) {
                return image
            }
        }

        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            for url in urls {
                if let image = NSImage(contentsOf: url) {
                    return image
                }
            }
        }

        for item in pasteboard.pasteboardItems ?? [] {
            if let fileURLString = item.string(forType: .fileURL),
               let url = URL(string: fileURLString),
               let image = NSImage(contentsOf: url) {
                return image
            }

            for type in item.types {
                if let data = item.data(forType: type), let image = NSImage(data: data) {
                    return image
                }
            }
        }

        return nil
    }
}
#endif
