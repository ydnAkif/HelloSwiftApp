import Cocoa

/// Owns and configures the main application window.
@MainActor
class MainWindowController: NSWindowController {

    /// Creates the main window with a default size and hosts `MainViewController`.
    convenience init() {
        let rect = NSRect(x: 0, y: 0, width: 500, height: 400)
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]

        let window = NSWindow(
            contentRect: rect,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )

        window.title = "HelloSwiftApp - Organize Sürüm 🛠️"

        self.init(window: window)
        self.contentViewController = MainViewController()

        // Calling `window.center()` after `self.init(window:)` is safer.
        window.center()
    }
}
