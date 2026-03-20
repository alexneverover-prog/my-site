<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
#if canImport(AppKit)
=======
#if os(macOS)
>>>>>>> theirs
=======
#if os(macOS)
>>>>>>> theirs
=======
#if os(macOS)
>>>>>>> theirs
import SwiftUI

struct ToolbarView: View {
    @ObservedObject var viewModel: InspectorViewModel

    var body: some View {
<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.appName)
                    .font(.system(size: 24, weight: .semibold))
                Text(viewModel.statusText)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("UI Inspector")
                    .font(.system(size: 28, weight: .bold))
                Text(viewModel.analysisSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
<<<<<<< ours
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
            }

            Spacer()

<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
            SummaryPill(title: L10n.critical, value: viewModel.criticalCount, tint: .red)
            SummaryPill(title: L10n.warningsPlural, value: viewModel.warningCount, tint: .orange)

            Button(L10n.upload) {
                viewModel.openImporter()
            }
            .buttonStyle(.bordered)

            Button(L10n.paste) {
                viewModel.pasteFromClipboard()
            }
            .buttonStyle(.bordered)

            Button(viewModel.isAnalyzing ? L10n.analyzing : L10n.analyze) {
                viewModel.analyze()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.screenshot == nil || viewModel.isAnalyzing)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(.thinMaterial)
    }
}

private struct SummaryPill: View {
    let title: String
    let value: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(tint.opacity(0.08))
        )
    }
}
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs
            Button("Upload") {
                #if os(macOS)
                viewModel.openImagePicker()
                #endif
            }
            .buttonStyle(.bordered)

            Button {
                viewModel.analyze()
            } label: {
                if viewModel.isAnalyzing {
                    ProgressView()
                        .controlSize(.small)
                        .frame(width: 80)
                } else {
                    Text("Analyze")
                        .frame(width: 80)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.loadedImage == nil || viewModel.isAnalyzing)
        }
    }
}

<<<<<<< ours
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
#endif
