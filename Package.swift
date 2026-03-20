// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UIInspector",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "UIInspectorApp", targets: ["UIInspectorApp"])
    ],
    targets: [
        .executableTarget(
            name: "UIInspectorApp",
            path: "Sources/UIInspectorApp",
            resources: [
                .copy("Resources/AppIcon.png")
            ]
        )
    ]
)
