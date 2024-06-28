// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AdswizzSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "AdswizzSDK",
            targets: ["AdswizzSDKTarget"]),
        .library(
            name: "AdswizzWatchSDK",
            targets: ["AdswizzWatchSDK"]),
        .library(
            name: "AdswizzSDKPinpointAnalytics",
            targets: ["AdswizzSDKPinpointAnalytics"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AdswizzSDKTarget",
            dependencies: [
                .target(name: "AdswizzSDK"),
                .target(name: "AdswizzSDKCore"),
            ],
            path: "AdswizzSDKTarget"
        ),
        .binaryTarget(
            name: "AdswizzSDK",
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/176543888.zip",
            checksum: "50da3c93a10497610554d5ccaa7b70a77d8bbea25187ea84a69a0d809c82829b"
        ),
        .binaryTarget(
            name: "AdswizzSDKCore",
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/176543895.zip",
            checksum: "fdc1df712785ea32b776345d2c4eff99b3234f20f25286866ab262b8629c4074"
        ),
        .binaryTarget(
            name: "AdswizzWatchSDK",
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/176543901.zip",
            checksum: "d89ea73ffc9e5b2480944d90a8c020cb12eb3d1c1b77a0417ac69a80f2f672fd"
        ),
        .binaryTarget(
            name: "AdswizzSDKPinpointAnalytics",
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/176543898.zip",
            checksum: "07c3fe4ed54d23fca1906d489b7aad6d3f8288217f66ed2caf92603230d38860"
        ),
    ]
)
