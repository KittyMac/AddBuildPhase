// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "AddBuildPhase",
    products: [
		.executable(name: "AddBuildPhase", targets: ["AddBuildPhase"]),
        .library(name: "AddBuildPhaseFramework", targets: ["AddBuildPhaseFramework"]),
    ],
    dependencies: [
		.package(url: "https://github.com/KittyMac/Ipecac.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "AddBuildPhase",
            dependencies: [
                "AddBuildPhaseFramework",
                "Ipecac",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "AddBuildPhaseFramework",
            dependencies: []),
        .testTarget(
            name: "AddBuildPhaseFrameworkTests",
            dependencies: ["AddBuildPhaseFramework"]),
    ]
)
