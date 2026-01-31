// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PiIsland",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PiIsland", targets: ["PiIsland"])
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.0")
    ],
    targets: [
        .executableTarget(
            name: "PiIsland",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ],
            path: "Sources/PiIsland",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
