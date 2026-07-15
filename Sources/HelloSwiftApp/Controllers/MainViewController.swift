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

    private var cachedSwiftVersion: String?
    private var swiftVersionTask: Task<String, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        swiftVersionTask = Task.detached(priority: .utility) { [weak self] in
            await self?.getSwiftVersion() ?? "Bilinmiyor"
        }
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
        if let logoPath = Bundle.module.path(forResource: "swift-logo", ofType: "png"),
            let logoImage = NSImage(contentsOfFile: logoPath)
        {
            logoButton.image = logoImage
            logoButton.imageScaling = .scaleProportionallyUpOrDown
        } else {
            infoLabel.stringValue =
                "Logo bulunamadı! (swift-logo.png dosyasının projeye 'Copy Bundle Resources' olarak eklendiğinden emin olun)"
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
            return
        }
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        isShowingInfo = true

        if let cached = cachedSwiftVersion {
            infoLabel.stringValue = "Swift: \(cached)  |  macOS: \(osVersion)"
            infoLabel.textColor = .secondaryLabelColor
            return
        }
        infoLabel.stringValue = "Sürüm bilgisi alınıyor..."
        infoLabel.textColor = .systemOrange

        if swiftVersionTask == nil {
            swiftVersionTask = Task.detached(priority: .utility) { [weak self] in
                await self?.getSwiftVersion() ?? "Bilinmiyor"
            }
        }

        Task { [weak self] in
            guard let self else { return }
            let swiftVersion = await (self.swiftVersionTask?.value ?? "Bilinmiyor")
            self.cachedSwiftVersion = swiftVersion

            // Kullanıcı bu arada kapattıysa etiketi ezme
            guard self.isShowingInfo else { return }
            self.infoLabel.stringValue = "Swift: \(swiftVersion)  |  macOS: \(osVersion)"
            self.infoLabel.textColor = .secondaryLabelColor
        }
    }

    private nonisolated func getSwiftVersion() async -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["swift", "--version"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
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
