// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "vuhnKredit",
    dependencies: [
        //.package(path: "../vuhnNetwork")
        .package(url: "https://github.com/vuhn-PhilWilson/vuhnNetwork", from: "0.0.4")
    ],
    targets: [
        .target(
            name: "vuhnKredit",
            dependencies: ["vuhnNetwork","CommandLineTool"]),
        .target(
            name: "CommandLineTool",
            dependencies: ["vuhnNetwork"]),
        .testTarget(
            name: "vuhnKreditTests",
            dependencies: ["vuhnKredit"]),
    ]
)
