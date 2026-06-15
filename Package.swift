// swift-tools-version:5.9
import PackageDescription

// AvasiaEngine is a pure-Swift, UI-free, fully testable game engine + content
// layer for the Avasia: King of Nacastrum iOS remake. The SwiftUI app (see the
// `App/` directory and `project.yml`) depends on this package.
let package = Package(
    name: "AvasiaEngine",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "AvasiaEngine", targets: ["AvasiaEngine"]),
        .library(name: "AvasiaSoCEngine", targets: ["AvasiaSoCEngine"])
    ],
    targets: [
        .target(
            name: "AvasiaEngine",
            path: "Sources/AvasiaEngine"
        ),
        .target(
            name: "AvasiaSoCEngine",
            dependencies: ["AvasiaEngine"],
            path: "Sources/AvasiaSoCEngine"
        ),
        .testTarget(
            name: "AvasiaEngineTests",
            dependencies: ["AvasiaEngine"],
            path: "Tests/AvasiaEngineTests"
        ),
        .testTarget(
            name: "AvasiaSoCEngineTests",
            dependencies: ["AvasiaSoCEngine", "AvasiaEngine"],
            path: "Tests/AvasiaSoCEngineTests"
        )
    ]
)
