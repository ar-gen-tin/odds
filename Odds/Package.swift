// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Odds",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Odds",
            path: "Sources",
            resources: [
                .copy("Resources/Fonts"),
                .copy("Resources/MenuBarIcon")
            ]
        )
    ]
)
