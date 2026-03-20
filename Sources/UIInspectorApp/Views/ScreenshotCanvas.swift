#if canImport(AppKit)
import SwiftUI

struct ScreenshotCanvas: View {
    @ObservedObject var viewModel: InspectorViewModel

    var body: some View {
        GeometryReader { proxy in
            let selection = viewModel.selectedIssue

            ZStack {
                Color.clear

                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(Color(red: 0.965, green: 0.965, blue: 0.975))
                    .padding(28)

                VStack(alignment: .leading, spacing: 22) {
                    header(selection: selection)

                    if let image = viewModel.screenshot {
                        contentLayout(for: image, in: proxy.size, selection: selection)
                    } else {
                        emptyState
                    }
                }
                .padding(68)
            }
        }
    }

    @ViewBuilder
    private func contentLayout(for image: NSImage, in size: CGSize, selection: Issue?) -> some View {
        let outerSize = canvasOuterSize(for: size)

        HStack(alignment: .top, spacing: 22) {
            screenshotPreview(image: image, outerSize: outerSize, selection: selection)

            VStack(spacing: 18) {
                detailCard(title: L10n.alignmentScoreTitle) {
                    let score = max(68, 100 - viewModel.issues.count * 2)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(L10n.alignmentScoreTitle)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.82))
                            Spacer()
                            Text("\(score)%")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.45))
                        }

                        ZStack(alignment: .leading) {
                            Capsule(style: .continuous)
                                .fill(Color.black.opacity(0.08))
                                .frame(height: 16)

                            Capsule(style: .continuous)
                                .fill(Color.black.opacity(0.92))
                                .frame(width: CGFloat(score) * 2.4, height: 16)
                        }
                    }
                }

                detailCard(title: L10n.recommendationsTitle) {
                    VStack(alignment: .leading, spacing: 18) {
                        if let selection {
                            Text(selection.recommendation)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(Color.black.opacity(0.8))

                            Text(selection.description)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.black.opacity(0.45))
                        } else {
                            Text(L10n.noResultsDescription)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.black.opacity(0.5))
                        }
                    }
                }
            }
            .frame(width: min(320, size.width * 0.28))
        }
    }

    private func header(selection: Issue?) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.currentScreenTitleLabel)
                    .font(.system(size: 22, weight: .semibold, design: .default))
                    .tracking(6)
                    .foregroundStyle(Color.black.opacity(0.55))
                    .multilineTextAlignment(.leading)

                Text(viewModel.currentScreenTitle)
                    .font(.system(size: 44, weight: .semibold))
                    .tracking(-1.5)
                    .foregroundStyle(Color.black.opacity(0.94))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            Text(viewModel.findingsCountText)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color(red: 0.0, green: 0.43, blue: 0.89))
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color(red: 0.89, green: 0.93, blue: 1.0))
                )
        }
    }

    private func screenshotPreview(image: NSImage, outerSize: CGSize, selection: Issue?) -> some View {
        let layout = FittedImageLayout(
            imageSize: image.size,
            containerSize: CGSize(width: outerSize.width - 80, height: outerSize.height - 80)
        )

        return ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )
                .padding(42)

            ZStack(alignment: .topLeading) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: layout.drawSize.width, height: layout.drawSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                ForEach(sortedIssues(viewModel.issues, selectedID: viewModel.selectedIssueID)) { issue in
                    let rect = layout.project(issue.frame)
                    let isSelected = issue.id == viewModel.selectedIssueID

                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(issue.severity.overlayColor.opacity(overlayOpacity(isSelected: isSelected, hasSelection: selection != nil)))
                        .frame(width: max(rect.width, 28), height: max(rect.height, 28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(isSelected ? issue.severity.color.opacity(0.9) : .white.opacity(0.5), lineWidth: isSelected ? 2.5 : 1)
                        )
                        .offset(x: rect.minX, y: rect.minY)
                        .shadow(color: issue.severity.color.opacity(isSelected ? 0.2 : 0), radius: 14, x: 0, y: 6)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedIssueID)
                }
            }
            .frame(width: layout.drawSize.width, height: layout.drawSize.height, alignment: .topLeading)
        }
        .frame(width: outerSize.width, height: outerSize.height)
    }

    private func detailCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.9))

            content()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            UploadPanel(viewModel: viewModel)
                .frame(maxWidth: 520)

            VStack(spacing: 10) {
                Text(L10n.previewTitle)
                    .font(.system(size: 26, weight: .semibold))
                Text(L10n.previewDescription)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

        return hasSelection ? 0.1 : 0.17
    }

    private func canvasOuterSize(for size: CGSize) -> CGSize {
        CGSize(
            width: min(max(size.width * 0.44, 380), 520),
            height: min(max(size.height * 0.58, 440), 760)
        )
    }
}

private struct FittedImageLayout {
    let imageSize: CGSize
    let containerSize: CGSize

    var scale: CGFloat {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return 1
        }

        let availableWidth = max(containerSize.width, 1)
        let availableHeight = max(containerSize.height, 1)
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
#endif
