// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Data",
            targets: ["Data"]
        )
    ],
    dependencies: [
        // External dependency – using the latest Moya release.
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        // Local dependency on Domain.
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                .product(name: "Moya", package: "Moya")
            ],
            path: "Sources/Data"
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data", "Domain"],
            path: "Tests/DataTests"
        )
    ]
)
