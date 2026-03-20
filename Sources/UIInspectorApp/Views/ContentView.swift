<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
#if canImport(AppKit)
import SwiftUI
import UniformTypeIdentifiers
=======
#if os(macOS)
import SwiftUI
>>>>>>> theirs
=======
#if os(macOS)
import SwiftUI
>>>>>>> theirs
=======
#if os(macOS)
import SwiftUI
>>>>>>> theirs

struct ContentView: View {
    @ObservedObject var viewModel: InspectorViewModel

    var body: some View {
<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
        VStack(spacing: 0) {
            ToolbarView(viewModel: viewModel)

            HStack(spacing: 0) {
                UploadPanel(viewModel: viewModel)
                    .frame(width: 290)

                ScreenshotCanvas(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                IssuesSidebar(viewModel: viewModel)
                    .frame(width: 350)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
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
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs
        NavigationStack {
            VStack(spacing: 0) {
                ToolbarView(viewModel: viewModel)
                    .padding(20)
                    .background(.ultraThinMaterial)

                HStack(spacing: 0) {
                    UploadPanel(viewModel: viewModel)
                        .frame(minWidth: 280, maxWidth: 320)
                        .background(Color(nsColor: .windowBackgroundColor))

                    Divider()

                    ScreenshotCanvas(viewModel: viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.02))

                    Divider()

                    IssuesSidebar(viewModel: viewModel)
                        .frame(minWidth: 320, maxWidth: 360)
                        .background(Color(nsColor: .controlBackgroundColor))
                }
            }
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
