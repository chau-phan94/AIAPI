// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AIAPI",
    platforms: [
        .iOS(.v13),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AIAPI",
            targets: ["AIAPI"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AIAPI"),
        .testTarget(
            name: "AIAPITests",
            dependencies: ["AIAPI"]
        ),
    ],
    swiftLanguageVersions: [.v5] // Specify the Swift language version
)
