// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WQTerm",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "WQTermCore", targets: ["WQTermCore"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WQTermCore",
            path: "WQTerm",
            exclude: [
                "Info.plist",
                "WQTerm.entitlements",
                "Localizable.strings",
                "Assets.xcassets",
                "App/AppDelegate.swift"
            ],
            resources: [
                .copy("Resources/ios_system"),
                .copy("Resources/node-ios-arm64"),
                .copy("Resources/node_modules"),
                .copy("Resources/Recipes")
            ]
        )
    ]
)

