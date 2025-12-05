// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tetris",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Tetris", targets: ["Tetris"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Tetris",
            dependencies: [],
            path: "Sources",
            resources: [],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Info.plist"])
            ]
        ),
    ]
)