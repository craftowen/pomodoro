// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Pomodoro",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Pomodoro",
            dependencies: [
                "KeyboardShortcuts"
            ],
            path: "Pomodoro",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
