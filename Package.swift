// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LeakDetector",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "LeakDetectorCore",
            targets: ["LeakDetectorCore"]
        ),
        .library(
            name: "LeakDetectorCombine",
            targets: ["LeakDetectorCombine"]
        ),
        .library(
            name: "LeakDetectorRxSwift",
            targets: ["LeakDetectorRxSwift"]
        ),
    ],
    dependencies: [
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift.git",
            .upToNextMajor(from: "6.0.0")
        ),
    ],
    targets: [
        .target(
            name: "LeakDetectorCore",
            dependencies: []
        ),
        
        .target(
            name: "LeakDetectorCombine",
            dependencies: [
                "LeakDetectorCore",
            ]
        ),
        
        .target(
            name: "LeakDetectorRxSwift",
            dependencies: [
                "LeakDetectorCore",
                "RxSwift",
                .product(name: "RxCocoa", package: "RxSwift"),
            ]
        ),
        
        .testTarget(
            name: "LeakDetectorTests",
            dependencies: [
                "LeakDetectorCore",
                "LeakDetectorCombine",
                "LeakDetectorRxSwift",
            ]
        ),
    ]
)
