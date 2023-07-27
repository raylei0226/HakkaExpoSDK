// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hakkaExpo",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HakkaExpo2023-iOS",
            targets: ["HakkaExpo2023-iOS"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HakkaExpo2023-iOS"),
        .testTarget(
            name: "Demo",
            dependencies: ["HakkaExpo2023-iOS"]),
    ]
)
