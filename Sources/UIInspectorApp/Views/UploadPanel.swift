#if canImport(AppKit)
import SwiftUI
import UniformTypeIdentifiers

struct UploadPanel: View {
    @ObservedObject var viewModel: InspectorViewModel
    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(L10n.dropScreenshotTitle)
                .font(.system(size: 22, weight: .semibold))

            Text(L10n.dropScreenshotDescription)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            Button(L10n.chooseFile) {
                viewModel.openImporter()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(isTargeted ? Color.accentColor.opacity(0.12) : Color.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                .foregroundStyle(isTargeted ? Color.accentColor.opacity(0.9) : Color.black.opacity(0.12))
        )
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else {
            return false
        }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }

            Task { @MainActor in
                viewModel.loadImage(from: url)
            }
        }

        return true
    }
}
#endif
