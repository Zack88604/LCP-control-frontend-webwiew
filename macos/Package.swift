// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "LCPControlMac",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "LCPControlMac", targets: ["LCPControlMac"]),
    ],
    targets: [
        .executableTarget(
            name: "LCPControlMac",
            path: "Sources/LCPControlMac"
        ),
    ]
)
