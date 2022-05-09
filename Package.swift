// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cronParser",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "cronParser",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
        .testTarget(
            name: "cronParserTests",
            dependencies: ["cronParser"]
        )
    ]
)
