import Cocoa

@MainActor
class MainViewController: NSViewController {

    private let logoButton = NSButton()
    private let infoLabel = NSTextField(
        labelWithString: "Sürüm bilgilerini görmek için logoya tıkla! 👇")

    private var isShowingInfo = false
    private let defaultWelcomeMessage = "Sürüm bilgilerini görmek için logoya tıkla! 👇"

    override func loadView() {
        let viewSize = NSRect(x: 0, y: 0, width: 500, height: 400)
        self.view = NSView(frame: viewSize)
        // M-serisi GPU hızlandırması için kritik
        self.view.wantsLayer = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // 1. Bilgi Etiketi
        infoLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        infoLabel.textColor = .secondaryLabelColor
        infoLabel.alignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)

        // 2. Swift Logo Butonu
        logoButton.isBordered = false
        logoButton.translatesAutoresizingMaskIntoConstraints = false
        logoButton.target = self
        logoButton.action = #selector(logoClicked)

        // Sadece hücre (cell) üzerinden border ayarı yapılır
        if let cell = logoButton.cell as? NSButtonCell {
            cell.showsBorderOnlyWhileMouseInside = false
        }

        // 3. GÜVENLİ RESİM YÜKLEME (Bundle Yöntemi)
        // currentDirectoryPath yerine Bundle kullanmak zorundayız.
        let resourcesPath = Bundle.main.resourcePath ?? "."
        let logoPath = "\(resourcesPath)/swift-logo.png"
        let sourcePath =
            "\(FileManager.default.currentDirectoryPath)/Sources/HelloSwiftApp/Resources/swift-logo.png"

        if let logoImage = NSImage(contentsOfFile: logoPath) {
            logoButton.image = logoImage
            logoButton.imageScaling = .scaleProportionallyUpOrDown
        } else if let logoImage = NSImage(contentsOfFile: sourcePath) {
            logoButton.image = logoImage
            logoButton.imageScaling = .scaleProportionallyUpOrDown
        } else {
            // Eğer "swift-logo" adı ile bulunamazsa, kullanıcıya nazik bir hata göster
            infoLabel.stringValue =
                "Logo bulunamadı! (swift-logo.png dosyasının projeye 'Copy Bundle Resources' olarak eklendiğinden emin olun) ⚠️"
            infoLabel.textColor = .systemRed
        }

        view.addSubview(logoButton)

        // 4. Auto Layout
        NSLayoutConstraint.activate([
            logoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            logoButton.widthAnchor.constraint(equalToConstant: 120),
            logoButton.heightAnchor.constraint(equalToConstant: 120),

            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: logoButton.bottomAnchor, constant: 30),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    @objc private func logoClicked() {
        if isShowingInfo {
            infoLabel.stringValue = defaultWelcomeMessage
            infoLabel.textColor = .secondaryLabelColor
            isShowingInfo = false
        } else {
            let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
            let swiftVersion = getSwiftVersion()

            infoLabel.stringValue = "Swift: \(swiftVersion)  |  macOS: \(osVersion)"
            infoLabel.textColor = .systemOrange
            isShowingInfo = true
        }
    }

    private func getSwiftVersion() -> String {
        let process = Process()
        process.launchPath = "/usr/bin/xcrun"
        process.arguments = ["swift", "--version"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // "Swift version 6.3.3 (swift-6.3.3-RELEASE)" gibi bir string döner
                if let range = output.range(of: "Swift version ") {
                    let versionString = String(output[range.upperBound...])
                    if let spaceIndex = versionString.firstIndex(of: " ") {
                        return String(versionString[..<spaceIndex])
                    }
                }
            }
        } catch {
            print("Swift version alınamadı: \(error)")
        }

        return "Bilinmiyor"
    }
}
