// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NDGeometry",
    platforms: [
        .macOS(.v14),
        .iOS(.v15)
    ],
    products: [
        .library(name: "NDGeometry", targets: ["NDGeometry"])
    ],
    dependencies: [
        // DocC plugin (command plugin that adds `generate-documentation`)
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "NDGeometry",
            dependencies: [],
            path: "Sources/NDGeometry"
        ),
        .testTarget(
            name: "NDGeometryTests",
            dependencies: ["NDGeometry"]
        )
    ]
)
