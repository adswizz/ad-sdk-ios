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
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/176228093.zip",
            checksum: "3186183c1aea42f8ccd7a07235106afd0e669e15c84834c0ae4280fd9292e55a"
        ),
        .binaryTarget(
            name: "AdswizzSDKCore",
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/176228104.zip",
            checksum: "664c3984faf676c8ae5a49cbabd95721ddc46a55750504e54536cf6cee1799c8"
        ),
        .binaryTarget(
            name: "AdswizzWatchSDK",
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/176228129.zip",
            checksum: "26c64c32449bda113fa8d326ef50a6cc2305e5df68964527fc4ba4df3df0b948"
        ),
        .binaryTarget(
            name: "AdswizzSDKPinpointAnalytics",
            url: "https://api.github.com/repos/adswizz/ad-sdk-ios/releases/assets/176228120.zip",
            checksum: "039f96ea060979527443f8999c5b34f87b02a08a5e55e9b43eccd67046cd3d2c"
        ),
    ]
)
