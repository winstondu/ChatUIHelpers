// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ChatUIHelpers",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "ChatUIHelpers",
            targets: ["ChatUIHelpers"]
        ),
    ],
    dependencies: [
        .package(path: "../UIFoundationHelpers"),
    ],
    targets: [
        .target(
            name: "ChatUIHelpers",
            dependencies: [
                .product(name: "WinstonUIFoundation", package: "uifoundationhelpers"),
            ],
            path: "."
        ),
    ]
)
