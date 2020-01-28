// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "vuhnKredit",
    dependencies: [
        //.package(path: "../vuhnNetwork")
        .package(url: "https://github.com/vuhn-PhilWilson/vuhnNetwork", from: "0.0.2")
    ],
    targets: [
        .target(
            name: "vuhnKredit",
            dependencies: ["vuhnNetwork","CommandLineTool","ConfigurationTool", "FileService"]),
        .target(
            name: "FileService",
            dependencies: []),
        .target(
            name: "ConsoleOutputTool",
            dependencies: ["vuhnNetwork"]),
        .target(
            name: "CommandLineTool",
            dependencies: ["vuhnNetwork", "ConfigurationTool", "ConsoleOutputTool"]),
        .target(
            name: "ConfigurationTool",
            dependencies: ["ConsoleOutputTool", "FileService"]),
        .testTarget(
            name: "vuhnKreditTests",
            dependencies: ["vuhnKredit", "ConfigurationTool"]),
    ]
)

