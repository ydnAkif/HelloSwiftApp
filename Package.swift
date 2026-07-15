// swift-tools-version: 6.3.3
import PackageDescription

let package = Package(
    name: "HelloSwiftApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "HelloSwiftApp", targets: ["HelloSwiftApp"])
    ],
    targets: [
        .executableTarget(
            name: "HelloSwiftApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
