<<<<<<< ours
#if canImport(AppKit)
import SwiftUI
=======
#if os(macOS)
import SwiftUI
#if os(macOS)
import AppKit
import AVFoundation
#endif
>>>>>>> theirs

struct ScreenshotCanvas: View {
    @ObservedObject var viewModel: InspectorViewModel

    var body: some View {
        GeometryReader { proxy in
            ZStack {
<<<<<<< ours
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(nsColor: .underPageBackgroundColor))

                if let image = viewModel.screenshot {
                    let layout = FittedImageLayout(imageSize: image.size, containerSize: proxy.size)
                    let hasSelection = viewModel.selectedIssueID != nil

                    ZStack(alignment: .topLeading) {
                        Image(nsImage: image)
                            .resizable()
                            .interpolation(.high)
                            .frame(width: layout.drawSize.width, height: layout.drawSize.height)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                        ForEach(sortedIssues(viewModel.issues, selectedID: viewModel.selectedIssueID)) { issue in
                            let rect = layout.project(issue.frame)
                            let isSelected = issue.id == viewModel.selectedIssueID

                            RoundedRectangle(cornerRadius: 14)
                                .fill(issue.severity.overlayColor.opacity(overlayOpacity(isSelected: isSelected, hasSelection: hasSelection)))
                                .frame(width: max(rect.width, 24), height: max(rect.height, 24))
                                .offset(x: rect.minX, y: rect.minY)
                                .shadow(
                                    color: issue.severity.overlayColor.opacity(isSelected ? 0.24 : 0),
                                    radius: isSelected ? 16 : 0,
                                    x: 0,
                                    y: 4
                                )
                                .scaleEffect(isSelected ? 1.02 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedIssueID)
                        }
                    }
                    .frame(width: layout.drawSize.width, height: layout.drawSize.height, alignment: .topLeading)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "rectangle.and.text.magnifyingglass")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                        Text(L10n.previewTitle)
                            .font(.title3.weight(.semibold))
                        Text(L10n.previewDescription)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
=======
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 20, y: 8)

                if let loadedImage = viewModel.loadedImage {
                    ZoomableImage(image: loadedImage)
                        .overlay {
                            IssueOverlay(
                                elements: viewModel.elements,
                                issues: viewModel.issues,
                                selectedIssue: viewModel.selectedIssue,
                                canvasSize: proxy.size
                            )
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(20)
                } else {
                    ContentUnavailableView(
                        "Нет скриншота",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("После загрузки интерфейса здесь появится превью и overlay с подсветкой проблемных зон.")
                    )
>>>>>>> theirs
                }
            }
            .padding(24)
        }
<<<<<<< ours
        .background(Color(nsColor: .textBackgroundColor))
    }

    private func sortedIssues(_ issues: [Issue], selectedID: Issue.ID?) -> [Issue] {
        issues.sorted { lhs, rhs in
            let lhsSelected = lhs.id == selectedID
            let rhsSelected = rhs.id == selectedID

            if lhsSelected != rhsSelected {
                return !lhsSelected
            }

            return lhs.severity == .warning && rhs.severity == .critical
        }
    }

    private func overlayOpacity(isSelected: Bool, hasSelection: Bool) -> Double {
        if isSelected {
            return 0.34
        }

        return hasSelection ? 0.09 : 0.16
    }
}

private struct FittedImageLayout {
    let imageSize: CGSize
    let containerSize: CGSize

    var scale: CGFloat {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return 1
        }

        let availableWidth = max(containerSize.width - 48, 1)
        let availableHeight = max(containerSize.height - 48, 1)
        return min(availableWidth / imageSize.width, availableHeight / imageSize.height)
    }

    var drawSize: CGSize {
        CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }

    func project(_ rect: CGRect) -> CGRect {
        CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )
    }
}
=======
    }
}

private struct ZoomableImage: View {
    let image: PlatformImage

    var body: some View {
        #if os(macOS)
        Image(nsImage: image)
            .resizable()
            .scaledToFit()
        #else
        Color.clear
        #endif
    }
}

private struct IssueOverlay: View {
    let elements: [UIElement]
    let issues: [Issue]
    let selectedIssue: Issue?
    let canvasSize: CGSize

    var body: some View {
        GeometryReader { geo in
            let imageRect = AVMakeRect(aspectRatio: contentAspectRatio, insideRect: geo.frame(in: .local))
            ZStack {
                ForEach(issues) { issue in
                    if let element = element(for: issue) {
                        let rect = scaledRect(for: element.frame, imageRect: imageRect)
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(issue.severity.color, lineWidth: selectedIssue?.id == issue.id ? 4 : 2)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(issue.severity.color.opacity(selectedIssue?.id == issue.id ? 0.22 : 0.10))
                            )
                            .frame(width: rect.width, height: rect.height)
                            .position(x: rect.midX, y: rect.midY)
                            .animation(.easeInOut(duration: 0.2), value: selectedIssue?.id)
                    }
                }
            }
        }
    }

    private var contentAspectRatio: CGSize {
        let union = elements.map(\.frame).reduce(CGRect.null) { $0.union($1) }
        guard !union.isNull else { return CGSize(width: 16, height: 10) }
        return union.size
    }

    private func element(for issue: Issue) -> UIElement? {
        guard let elementID = issue.elementID else { return nil }
        return elements.first(where: { $0.id == elementID })
    }

    private func scaledRect(for rect: CGRect, imageRect: CGRect) -> CGRect {
        let union = elements.map(\.frame).reduce(CGRect.null) { $0.union($1) }
        guard !union.isNull else { return .zero }
        let scaleX = imageRect.width / union.width
        let scaleY = imageRect.height / union.height
        return CGRect(
            x: imageRect.minX + (rect.minX - union.minX) * scaleX,
            y: imageRect.minY + (rect.minY - union.minY) * scaleY,
            width: rect.width * scaleX,
            height: rect.height * scaleY
        )
    }
}

>>>>>>> theirs
#endif
