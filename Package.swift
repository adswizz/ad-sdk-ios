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
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/192925777.zip",
            checksum: "7114e711acd7e11dbacc25e99427637ae27056cc076529d437e5d66504850a0d"
        ),
        .binaryTarget(
            name: "AdswizzSDKCore",
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/192925782.zip",
            checksum: "6ac224c31bb6637c2226015ba65aa8fad73f8f786d9c643a14d118f2d2c49883"
        ),
        .binaryTarget(
            name: "AdswizzWatchSDK",
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/192925784.zip",
            checksum: "df9c853ed973f896b5ea4877048188745e1d26d233005a68a1a20bd0a32edd46"
        ),
        .binaryTarget(
            name: "AdswizzSDKPinpointAnalytics",
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/192925783.zip",
            checksum: "9390f805b2dc789c7e557f21ae40b00657efbb9cd8116bf08ed50265423e41e4"
        ),
    ]
)
