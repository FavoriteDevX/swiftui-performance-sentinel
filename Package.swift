// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swiftui-performance-sentinel",
    platforms: [.iOS(.v16), .macOS(.v13), .watchOS(.v9), .tvOS(.v16), .visionOS(.v1)],
    products: [
        .library(name: "PerformanceSentinel", targets: ["PerformanceSentinel"]),
    ],
    targets: [
        .target(name: "PerformanceSentinel", dependencies: []),
    ]
)
