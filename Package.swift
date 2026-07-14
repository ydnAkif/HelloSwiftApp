// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "HelloSwiftApp",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "HelloSwiftApp",
            dependencies: [],
            // SPM'e Resources klasörünü işlemesini söylüyoruz
            resources: [
                .process("Resources")
            ]
        )
    ]
)
