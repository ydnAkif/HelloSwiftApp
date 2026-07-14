import Cocoa

@MainActor
class MainWindowController: NSWindowController {

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
        window.center()

        self.init(window: window)
        self.contentViewController = MainViewController()
    }
}
