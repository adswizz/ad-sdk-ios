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
        .library(
            name: "AdswizzSDKPrivacyDataCalendar",
            targets: ["AdswizzSDKPrivacyDataCalendar"]),
        .library(
            name: "AdswizzSDKPrivacyDataCamera",
            targets: ["AdswizzSDKPrivacyDataCamera"]),
        .library(
            name: "AdswizzSDKPrivacyDataContacts",
            targets: ["AdswizzSDKPrivacyDataContacts"]),
        .library(
            name: "AdswizzSDKPrivacyDataIDFA",
            targets: ["AdswizzSDKPrivacyDataIDFA"]),
        .library(
            name: "AdswizzSDKPrivacyDataLocation",
            targets: ["AdswizzSDKPrivacyDataLocation"]),
        .library(
            name: "AdswizzSDKPrivacyDataMicrophone",
            targets: ["AdswizzSDKPrivacyDataMicrophone"]),
        .library(
            name: "AdswizzSDKPrivacyDataMotion",
            targets: ["AdswizzSDKPrivacyDataMotion"]),
        .library(
            name: "AdswizzSDKPrivacyDataPhotos",
            targets: ["AdswizzSDKPrivacyDataPhotos"]),
        .library(
            name: "AdswizzSDKPrivacyDataSpeech",
            targets: ["AdswizzSDKPrivacyDataSpeech"]),
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
            path: "Framework/AdswizzSDK.xcframework"
        ),
        .binaryTarget(
            name: "AdswizzSDKCore",
            path: "Framework/AdswizzSDKCore.xcframework"
        ),
        .binaryTarget(
            name: "AdswizzWatchSDK",
            path: "Framework/AdswizzWatchSDK.xcframework"
        ),
        .binaryTarget(
            name: "AdswizzSDKPinpointAnalytics",
            path: "Framework/AdswizzSDKPinpointAnalytics.xcframework"
        ),
        .binaryTarget(
            name: "AdswizzSDKPrivacyDataCore",
            path: "Framework/AdswizzSDKPrivacyDataCore.xcframework"
        ),
        .target(
            name: "AdswizzSDKPrivacyDataCalendar",
            dependencies: [.target(name: "AdswizzSDKPrivacyDataCore")],
            path: "AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataCalendar"
        ),
        .target(
            name: "AdswizzSDKPrivacyDataCamera",
            dependencies: [.target(name: "AdswizzSDKPrivacyDataCore")],
            path: "AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataCamera"
        ),
        .target(
            name: "AdswizzSDKPrivacyDataContacts",
            dependencies: [.target(name: "AdswizzSDKPrivacyDataCore")],
            path: "AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataContacts"
        ),
        .target(
            name: "AdswizzSDKPrivacyDataIDFA",
            dependencies: [.target(name: "AdswizzSDKPrivacyDataCore")],
            path: "AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataIDFA"
        ),
        .target(
            name: "AdswizzSDKPrivacyDataLocation",
            dependencies: [.target(name: "AdswizzSDKPrivacyDataCore")],
            path: "AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataLocation"
        ),
        .target(
            name: "AdswizzSDKPrivacyDataMicrophone",
            dependencies: [.target(name: "AdswizzSDKPrivacyDataCore")],
            path: "AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataMicrophone"
        ),
        .target(
            name: "AdswizzSDKPrivacyDataMotion",
            dependencies: [.target(name: "AdswizzSDKPrivacyDataCore")],
            path: "AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataMotion"
        ),
        .target(
            name: "AdswizzSDKPrivacyDataPhotos",
            dependencies: [.target(name: "AdswizzSDKPrivacyDataCore")],
            path: "AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataPhotos"
        ),
        .target(
            name: "AdswizzSDKPrivacyDataSpeech",
            dependencies: [.target(name: "AdswizzSDKPrivacyDataCore")],
            path: "AdswizzSDKPrivacyDataKit/AdswizzSDKPrivacyDataSpeech"
        )
    ]
)
