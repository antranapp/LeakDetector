// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LeakDetector",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(
            name: "LeakDetector",
            targets: ["LeakDetector"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LeakDetector",
            dependencies: []
        ),
        .testTarget(
            name: "LeakDetectorTests",
            dependencies: ["LeakDetector"]
        ),
    ]
)
