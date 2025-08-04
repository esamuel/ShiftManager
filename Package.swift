// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShiftManager",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ShiftManager",
            targets: ["ShiftManager"]),
    ],
    dependencies: [
        // Firebase dependencies removed
    ],
    targets: [
        .target(
            name: "ShiftManager",
            dependencies: [
                // Firebase products removed
            ]),
        .testTarget(
            name: "ShiftManagerTests",
            dependencies: ["ShiftManager"]),
    ]
) 