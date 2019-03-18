// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "GIO",
    products: [
        .library(name: "GIO", targets: ["GIO"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Brett-Best/SwiftGObject.git", .branch("bb-pkg-dev"))
    ],
    targets: [
        .target(name: "GIO", dependencies: ["GLibObject"]),
        .testTarget(name: "GIOTests", dependencies: ["GIO"]),
    ]
)
