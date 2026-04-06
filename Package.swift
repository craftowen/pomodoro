// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Pomodoro",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Pomodoro",
            dependencies: [
                "KeyboardShortcuts",
                "Sparkle"
            ],
            path: "Pomodoro",
            exclude: ["Info.plist", "Pomodoro.entitlements"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
