// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WordFeature",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "WordFeature",
            targets: ["WordFeature"]
        )
    ],
    dependencies: [
        // Local dependency on Domain.
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "WordFeature",
            dependencies: [
                "Domain"
            ],
            path: "Sources/WordFeature"
        )
    ]
)
