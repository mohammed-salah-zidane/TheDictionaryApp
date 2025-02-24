// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Data", targets: ["Data"])
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: ["Domain"],
            path: "Sources/Data",
            resources: [
                // Make sure to process the .xcdatamodeld
                .process("Local/WordDefinitionModel.xcdatamodeld")
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data", "Domain"],
            path: "Tests/DataTests"
        )
    ]
)
