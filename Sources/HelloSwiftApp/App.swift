import Cocoa

@main
struct HelloSwiftApp {

    // Swift 6 Strict Concurrency için giriş noktasını da MainActor ile işaretliyoruz
    @MainActor
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.regular)

        let delegate = AppDelegate()
        app.delegate = delegate

        setupMainMenu()

        // app.run() bloklayan bir çağrıdır, delegate bu sayede bellekte canlı kalır.
        app.run()
    }

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
