import Cocoa

/// Application entry point and top-level app menu configuration.
@main
struct HelloSwiftApp {

    /// Marks the app entry point as `@MainActor` to satisfy Swift 6 strict
    /// concurrency requirements for AppKit UI code.
    @MainActor
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.regular)

        let delegate = AppDelegate()
        app.delegate = delegate

        setupMainMenu()

        // `app.run()` is a blocking call; this keeps the delegate alive
        // for the app lifecycle.
        app.run()
    }

    /// Creates a minimal application menu with a standard Quit action.
    @MainActor
    static func setupMainMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        let quitMenuItem = NSMenuItem(
            title: "Quit \(ProcessInfo.processInfo.processName)",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appMenu.addItem(quitMenuItem)

        NSApplication.shared.mainMenu = mainMenu
    }
}
