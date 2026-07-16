import Testing
import Cocoa
@testable import HelloSwiftApp

// MARK: - Swift Version Parsing Tests

@Test func testSwiftVersionParsing() {
    let output = "Swift version 5.9 (swift-5.9)\nTarget: macOS 13.0"
    let parsed = MainViewController.parseSwiftVersion(from: output)
    #expect(parsed == "5.9")
}

@Test func testSwiftVersionParsingEdgeCases() {
    let output1 = "Swift version 6.3.3 (swift-6.3.3-RELEASE)"
    let parsed1 = MainViewController.parseSwiftVersion(from: output1)
    #expect(parsed1 == "6.3.3")

    let output2 = "Swift version 5.10"
    let parsed2 = MainViewController.parseSwiftVersion(from: output2)
    #expect(parsed2 == "5.10")
}

@Test func testSwiftVersionParsingInvalidInput() {
    let output = "Some random text without version"
    let parsed = MainViewController.parseSwiftVersion(from: output)
    #expect(parsed == nil)
}

// MARK: - Swift Version Fetch Tests

@Test func testSwiftVersionFetch() async {
    let version = await MainViewController.fetchSwiftVersionWithTimeout(seconds: 2)
    #expect(!version.isEmpty)
    #expect(version != "Bilinmiyor")
}

// MARK: - MainViewController Tests

@Test @MainActor func testLogoButtonExists() {
    let viewController = MainViewController()
    _ = viewController.view // viewDidLoad + setupUI'yi tetikler
    // setupUI logoButton.isBordered = false yapıyor
    #expect(viewController.logoButton.isBordered == false)
}

@Test @MainActor func testInfoLabelInitialText() {
    let viewController = MainViewController()
    #expect(viewController.infoLabel.stringValue == "Sürüm bilgilerini görmek için logoya tıkla! 👇")
}

@Test @MainActor func testViewLoaded() {
    let viewController = MainViewController()
    _ = viewController.view // view'u yüklemek için tetikliyoruz
    #expect(viewController.view.frame.width == 500)
    #expect(viewController.view.frame.height == 400)
}

@Test @MainActor func testLogoClickChangesInfoLabel() {
    let viewController = MainViewController()
    let initialText = viewController.infoLabel.stringValue
    viewController.logoClicked()
    #expect(viewController.infoLabel.stringValue != initialText)
}

@Test @MainActor func testLogoClickToggleBack() {
    let viewController = MainViewController()
    let originalText = viewController.infoLabel.stringValue
    viewController.logoClicked() // bilgi göster
    viewController.logoClicked() // geri dön
    #expect(viewController.infoLabel.stringValue == originalText)
}

// MARK: - MainWindowController Tests

@Test @MainActor func testMainWindowControllerExists() {
    let windowController = MainWindowController()
    #expect(windowController.window != nil)
}

@Test @MainActor func testMainWindowTitle() {
    let windowController = MainWindowController()
    #expect(windowController.window?.title == "HelloSwiftApp - Organize Sürüm 🛠️")
}

@Test @MainActor func testMainWindowContentViewController() {
    let windowController = MainWindowController()
    #expect(windowController.contentViewController is MainViewController)
}

@Test @MainActor func testMainWindowSize() {
    let windowController = MainWindowController()
    // contentRect pencere iç alanını verir; frame macOS başlık çubuğunu da içerir
    let contentRect = windowController.window?.contentRect(forFrameRect: windowController.window!.frame)
    #expect(contentRect?.width == 500)
    #expect(contentRect?.height == 400)
}

// MARK: - AppDelegate Tests

@Test @MainActor func testApplicationShouldTerminateAfterLastWindowClosed() {
    let appDelegate = AppDelegate()
    let app = NSApplication.shared
    #expect(appDelegate.applicationShouldTerminateAfterLastWindowClosed(app) == true)
}

@Test @MainActor func testApplicationDidFinishLaunching() {
    let appDelegate = AppDelegate()
    let notification = Notification(name: NSApplication.didFinishLaunchingNotification)
    appDelegate.applicationDidFinishLaunching(notification)
    #expect(appDelegate.mainWindowController != nil)
}
