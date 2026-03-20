<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
#if canImport(AppKit)
import AppKit
import SwiftUI

extension Notification.Name {
    static let uiInspectorPasteFromClipboard = Notification.Name("UIInspectorPasteFromClipboard")
}

@main
struct UIInspectorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var viewModel = InspectorViewModel()

    var body: some Scene {
        WindowGroup(L10n.appName) {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 1180, minHeight: 760)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .pasteboard) {
                Button(L10n.paste) {
                    viewModel.pasteFromClipboard()
                }
                .keyboardShortcut("v", modifiers: [.command])
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "png"),
           let iconImage = NSImage(contentsOf: iconURL) {
            NSApp.applicationIconImage = iconImage
        }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.modifierFlags.contains(.command),
                  !event.modifierFlags.contains(.option),
                  !event.modifierFlags.contains(.control),
                  !event.modifierFlags.contains(.shift),
                  event.charactersIgnoringModifiers?.lowercased() == "v" else {
                return event
            }

            NotificationCenter.default.post(name: .uiInspectorPasteFromClipboard, object: nil)
            return nil
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs
#if os(macOS)
import SwiftUI

@main
struct UIInspectorMacApp: App {
    @StateObject private var viewModel = InspectorViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 1200, minHeight: 760)
        }
        .windowResizability(.contentSize)
<<<<<<< ours
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
    }
}
#endif
