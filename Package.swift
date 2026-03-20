<<<<<<< ours
// swift-tools-version: 5.9
=======
// swift-tools-version: 6.0
>>>>>>> theirs
import PackageDescription

let package = Package(
    name: "UIInspector",
    platforms: [
        .macOS(.v13)
    ],
    products: [
<<<<<<< ours
        .executable(name: "UIInspectorApp", targets: ["UIInspectorApp"])
=======
        .executable(name: "UIInspector", targets: ["UIInspectorApp"])
>>>>>>> theirs
    ],
    targets: [
        .executableTarget(
            name: "UIInspectorApp",
<<<<<<< ours
            path: "Sources/UIInspectorApp",
            resources: [
                .copy("Resources/AppIcon.png")
            ]
=======
            path: "Sources/UIInspectorApp"
>>>>>>> theirs
        )
    ]
)
