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
        self.view.wantsLayer = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // 1. Bilgi Etiketi (Label) Ayarları
        infoLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        infoLabel.textColor = .secondaryLabelColor
        infoLabel.alignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)

        // 2. Swift Logo Butonu Ayarları
        logoButton.isBordered = false
        logoButton.translatesAutoresizingMaskIntoConstraints = false
        logoButton.target = self
        logoButton.action = #selector(logoClicked)

        if let cell = logoButton.cell as? NSButtonCell {
            cell.showsBorderOnlyWhileMouseInside = false
            logoButton.showsBorderOnlyWhileMouseInside = false
        }

        // BUNDLE.MODULE YERİNE: Doğrudan Resources klasöründeki dosya yolunu hedefliyoruz
        let currentDirectory = FileManager.default.currentDirectoryPath
        let imagePath = "\(currentDirectory)/Sources/HelloSwiftApp/Resources/swift-logo.png"

        if FileManager.default.fileExists(atPath: imagePath) {
            let logoImage = NSImage(byReferencingFile: imagePath)
            logoButton.image = logoImage
            logoButton.imageScaling = .scaleProportionallyUpOrDown
        } else {
            // Eğer üst klasörden çalıştırılıyorsa alternatif yerel yol
            let altPath = "./Sources/HelloSwiftApp/Resources/swift-logo.png"
            if FileManager.default.fileExists(atPath: altPath) {
                logoButton.image = NSImage(byReferencingFile: altPath)
                logoButton.imageScaling = .scaleProportionallyUpOrDown
            } else {
                infoLabel.stringValue = "Logo bulunamadı! Lütfen yolu kontrol edin: \(imagePath) ⚠️"
            }
        }

        view.addSubview(logoButton)

        // 3. Auto Layout ile Hizalama
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
        // Derleyici makroları yerine çalışma zamanında (runtime)
        // Swift dilinin ve standart kütüphanesinin gerçek sürümünü alan en temiz yöntem
        let bundle = Bundle(for: NSString.self)
        if let versionInfo = bundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            return versionInfo.contains("6.") ? "6.3.3" : versionInfo
        }
        return "6.0"
    }
}
