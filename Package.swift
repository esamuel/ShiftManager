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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.19.0"))
    ],
    targets: [
        .target(
            name: "ShiftManager",
            dependencies: [
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk")
            ]),
        .testTarget(
            name: "ShiftManagerTests",
            dependencies: ["ShiftManager"]),
    ]
) 