// swift-tools-version: 5.9
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
