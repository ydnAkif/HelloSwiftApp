import Cocoa

/// Main content controller that displays the Swift logo and runtime version info.
@MainActor
class MainViewController: NSViewController {

    private let logoButton = NSButton()
    private let infoLabel = NSTextField(
        labelWithString: "Sürüm bilgilerini görmek için logoya tıkla! 👇")

    private var isShowingInfo = false
    private let defaultWelcomeMessage = "Sürüm bilgilerini görmek için logoya tıkla! 👇"
    private let swiftVersionTimeoutSeconds: UInt64 = 3

    override func loadView() {
        let viewSize = NSRect(x: 0, y: 0, width: 500, height: 400)
        self.view = NSView(frame: viewSize)
        // Important for GPU-accelerated rendering, especially on Apple Silicon.
        self.view.wantsLayer = true
    }

    private var cachedSwiftVersion: String?
    private var swiftVersionTask: Task<String, Never>?

    deinit {
        swiftVersionTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startSwiftVersionFetchIfNeeded()
    }

    /// Builds the UI hierarchy and constraints for the logo and info label.
    private func setupUI() {
        // 1) Info label
        infoLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        infoLabel.textColor = .secondaryLabelColor
        infoLabel.alignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)

        // 2) Swift logo button
        logoButton.isBordered = false
        logoButton.translatesAutoresizingMaskIntoConstraints = false
        logoButton.target = self
        logoButton.action = #selector(logoClicked)

        // Border behavior is configured through the underlying button cell.
        if let cell = logoButton.cell as? NSButtonCell {
            cell.showsBorderOnlyWhileMouseInside = false
        }

        // 3) Safe image loading from the module bundle
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

        // 4) Auto Layout constraints
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

    /// Toggles between welcome text and system/runtime version details.
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

        startSwiftVersionFetchIfNeeded()

        Task { [weak self] in
            guard let self else { return }
            let swiftVersion = await (self.swiftVersionTask?.value ?? "Bilinmiyor")
            self.swiftVersionTask = nil

            if swiftVersion != "Bilinmiyor" {
                self.cachedSwiftVersion = swiftVersion
            }

            // Do not overwrite the label if the user toggled back meanwhile.
            guard self.isShowingInfo else { return }
            self.infoLabel.stringValue = "Swift: \(swiftVersion)  |  macOS: \(osVersion)"
            self.infoLabel.textColor = .secondaryLabelColor
        }
    }

    /// Starts a background version fetch task if one is not already running.
    private func startSwiftVersionFetchIfNeeded() {
        guard swiftVersionTask == nil else { return }

        swiftVersionTask = Task(priority: .utility) { [swiftVersionTimeoutSeconds] in
            await Self.fetchSwiftVersionWithTimeout(seconds: swiftVersionTimeoutSeconds)
        }
    }

    /// Returns the first completed result between version fetch and timeout.
    /// - Parameter seconds: Timeout threshold in seconds.
    private nonisolated static func fetchSwiftVersionWithTimeout(seconds: UInt64) async -> String {
        await withTaskGroup(of: String.self) { group in
            group.addTask {
                await Self.getSwiftVersionNonBlocking()
            }

            group.addTask {
                try? await Task.sleep(nanoseconds: seconds * 1_000_000_000)
                return "Bilinmiyor"
            }

            let firstResult = await group.next() ?? "Bilinmiyor"
            group.cancelAll()
            return firstResult
        }
    }

    /// Runs `xcrun swift --version` asynchronously and extracts the Swift version.
    private nonisolated static func getSwiftVersionNonBlocking() async -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["swift", "--version"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()

            while process.isRunning {
                if Task.isCancelled {
                    process.terminate()
                    return "Bilinmiyor"
                }

                try? await Task.sleep(nanoseconds: 50_000_000)
            }

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else {
                return "Bilinmiyor"
            }

            return Self.parseSwiftVersion(from: output) ?? "Bilinmiyor"
        } catch {
            print("Swift version alınamadı: \(error)")
            return "Bilinmiyor"
        }
    }

    /// Parses a semantic version token from `swift --version` output.
    /// - Parameter output: Full stdout string from the command.
    /// - Returns: Version token (for example `6.2`) when available.
    private nonisolated static func parseSwiftVersion(from output: String) -> String? {
        let lines = output.split(separator: "\n")

        guard
            let versionLine = lines.first(where: {
                $0.localizedCaseInsensitiveContains("swift version")
            })
        else {
            return nil
        }

        let tokens = versionLine.split(whereSeparator: { $0.isWhitespace })
        guard let versionTokenIndex = tokens.firstIndex(where: { $0.lowercased() == "version" }),
            versionTokenIndex + 1 < tokens.count
        else {
            return nil
        }

        return String(tokens[versionTokenIndex + 1])
    }
}
