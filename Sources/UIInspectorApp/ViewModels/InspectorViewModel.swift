<<<<<<< ours
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
=======
#if os(macOS)
import Foundation
import SwiftUI
#if os(macOS)
import AppKit
import UniformTypeIdentifiers
#endif

@MainActor
final class InspectorViewModel: ObservableObject {
    @Published var loadedImage: PlatformImage?
    @Published var elements: [UIElement] = []
    @Published var issues: [Issue] = []
    @Published var selectedIssueID: Issue.ID?
    @Published var isAnalyzing = false
    @Published var dragIsActive = false
    @Published var analysisSummary = "Загрузите скриншот и запустите анализ."

    private let analyzer: UIAnalyzing

    init(analyzer: UIAnalyzing = UIAnalyzer()) {
        self.analyzer = analyzer
    }

    var selectedIssue: Issue? {
        issues.first { $0.id == selectedIssueID }
    }

    func selectIssue(_ issue: Issue) {
        selectedIssueID = issue.id
    }

    func analyze() {
        guard let loadedImage else {
            analysisSummary = "Сначала загрузите скриншот интерфейса."
            return
        }

        isAnalyzing = true
        analysisSummary = "Анализируем отступы, типографику и контраст…"

        Task {
            let result = await analyzer.analyze(image: loadedImage)
            elements = result.elements
            issues = result.issues
            selectedIssueID = result.issues.first?.id
            isAnalyzing = false
            analysisSummary = result.issues.isEmpty
                ? "Критичных UX/UI проблем не найдено."
                : "Найдено проблем: \(result.issues.count)"
        }
    }

    #if os(macOS)
    func openImagePicker() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.png, .jpeg, .tiff, .image]

        guard panel.runModal() == .OK, let url = panel.url, let image = NSImage(contentsOf: url) else {
            return
        }

        setImage(image)
    }

    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.canLoadObject(ofClass: NSImage.self) }) else {
            return false
        }

        provider.loadObject(ofClass: NSImage.self) { [weak self] image, _ in
            guard let image = image as? NSImage else { return }
            Task { @MainActor in
                self?.setImage(image)
            }
        }

        return true
    }

    private func setImage(_ image: NSImage) {
        loadedImage = image
        elements = []
        issues = []
        selectedIssueID = nil
        analysisSummary = "Скриншот загружен. Нажмите Analyze."
    }
    #endif
}

>>>>>>> theirs
#endif
