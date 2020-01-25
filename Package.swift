// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "vuhnKredit",
    dependencies: [
        //.package(path: "../vuhnNetwork")
        .package(url: "https://github.com/vuhn-PhilWilson/vuhnNetwork", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "vuhnKredit",
            dependencies: ["vuhnNetwork","CommandLineTool","ConfigurationTool"]),
        .target(
            name: "ConsoleOutputTool",
            dependencies: []),
        .target(
            name: "CommandLineTool",
            dependencies: ["vuhnNetwork", "ConfigurationTool", "ConsoleOutputTool"]),
        .target(
            name: "ConfigurationTool",
            dependencies: ["ConsoleOutputTool"]),
        .testTarget(
            name: "vuhnKreditTests",
            dependencies: ["vuhnKredit"]),
    ]
)

