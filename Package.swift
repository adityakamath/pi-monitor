// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PiMonitor",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PiMonitor", targets: ["PiMonitor"])
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.0")
    ],
    targets: [
        .executableTarget(
            name: "PiMonitor",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ],
            path: "Sources/PiMonitor",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
