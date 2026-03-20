#if canImport(AppKit)
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var viewModel: InspectorViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.965, green: 0.969, blue: 0.985)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.white.opacity(0.74))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 40, x: 0, y: 14)
                .padding(10)

            VStack(spacing: 0) {
                ToolbarView(viewModel: viewModel)

                Divider()
                    .overlay(Color.black.opacity(0.04))

                HStack(spacing: 0) {
                    IssuesSidebar(viewModel: viewModel)
                        .frame(width: 360)

                    Divider()
                        .overlay(Color.black.opacity(0.04))

                    ScreenshotCanvas(viewModel: viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(10)
        }
        .fileImporter(
            isPresented: $viewModel.isImporting,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let url = urls.first {
                viewModel.loadImage(from: url)
            }
        }
        .onPasteCommand(of: [.image, .png, .tiff, .fileURL]) { _ in
            viewModel.pasteFromClipboard()
        }
        .onReceive(NotificationCenter.default.publisher(for: .uiInspectorPasteFromClipboard)) { _ in
            viewModel.pasteFromClipboard()
        }
    }
}
#endif
