<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
#if canImport(AppKit)
import SwiftUI
import UniformTypeIdentifiers

struct UploadPanel: View {
    @ObservedObject var viewModel: InspectorViewModel
    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n.inputTitle)
                .font(.title2.weight(.semibold))

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.dropScreenshotTitle)
                    .font(.headline)
                Text(L10n.dropScreenshotDescription)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                Button(L10n.chooseFile) {
                    viewModel.openImporter()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(isTargeted ? Color.accentColor.opacity(0.14) : Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                    .foregroundStyle(isTargeted ? Color.accentColor : Color.secondary.opacity(0.4))
            )
            .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.checksTitle)
                    .font(.headline)

                heuristicRow(L10n.checkSpacing)
                heuristicRow(L10n.checkTypography)
                heuristicRow(L10n.checkContrast)
                heuristicRow(L10n.checkHierarchy)
                heuristicRow(L10n.checkClickability)
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs
#if os(macOS)
import SwiftUI
#if os(macOS)
import UniformTypeIdentifiers
#endif

struct UploadPanel: View {
    @ObservedObject var viewModel: InspectorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Загрузка")
                .font(.title2.bold())

            Text("Перетащите PNG/JPG скриншот или загрузите его кнопкой Upload.")
                .foregroundStyle(.secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(viewModel.dragIsActive ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundStyle(viewModel.dragIsActive ? Color.accentColor : Color.secondary)
                    )

                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 32))
                    Text("Drop screenshot here")
                        .font(.headline)
                    Text("Поддерживаются изображения интерфейсов для macOS, web и mobile.")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
            }
            .frame(height: 240)
            #if os(macOS)
            .onDrop(of: [UTType.image.identifier], isTargeted: $viewModel.dragIsActive) { providers in
                viewModel.handleDrop(providers: providers)
            }
            #endif

            VStack(alignment: .leading, spacing: 12) {
                Label("Эвристики MVP", systemImage: "sparkles.rectangle.stack")
                    .font(.headline)
                heuristicRow(text: "Текст < 16 pt → readability warning")
                heuristicRow(text: "Line-height < 1.3 → typography issue")
                heuristicRow(text: "Контраст < 4.5:1 → critical")
                heuristicRow(text: "Неровные spacing между карточками → inconsistency")
                heuristicRow(text: "CTA с низким контрастом / высотой < 40 pt → critical")
<<<<<<< ours
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
            }

            Spacer()
        }
        .padding(24)
<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private func heuristicRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 8, height: 8)
                .padding(.top, 5)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
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
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs
    }

    private func heuristicRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 7, height: 7)
                .padding(.top, 6)
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
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
