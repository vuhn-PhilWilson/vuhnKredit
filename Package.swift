// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "vuhnKredit",
    platforms: [
        .macOS(.v10_13)
    ],
    dependencies: [
//        .package(path: "../vuhnNetwork")
        .package(url: "https://github.com/vuhn-PhilWilson/vuhnNetwork", from: "0.0.5")
    ],
    targets: [
        .target(
            name: "vuhnKredit",
            dependencies: ["vuhnNetwork","CommandLineTool","ConfigurationTool", "FileService"]),
        .target(
            name: "FileService",
            dependencies: ["vuhnNetwork"]),
        .target(
            name: "CommandLineTool",
            dependencies: ["vuhnNetwork", "ConfigurationTool"]),
        .target(
            name: "ConfigurationTool",
            dependencies: ["FileService"]),
        .testTarget(
            name: "vuhnKreditTests",
            dependencies: ["vuhnKredit", "ConfigurationTool"]),
    ]
)

