// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyChrono",
    products: [
        .library(
            name: "SwiftyChrono",
            targets: ["SwiftyChrono"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftyChrono",
            path: "Sources",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "SwiftyChronoTests",
            dependencies: ["SwiftyChrono"],
            path: "Tests/SwiftyChronoTests",
            exclude: ["Info.plist"],
            resources: [],
            linkerSettings: [
                .linkedFramework("JavaScriptCore"),
            ]
        ),
    ]
)
