# AdswizzSDK - iOS Swift

The only audio-centric SDK to Drive Innovation & Differentiation in Audio monetization

## Requirements

* Xcode 26.0+ (latest recommended). **_AdswizzSDK_** `v8.0.0` binaries are built with Xcode 26.4.1 and Swift 6, so your toolchain needs a Swift 6 compiler to read the concurrency annotations they export
* Swift 5.9+ if your app is written in Swift or Objective-C. Your app may stay in the **Swift 5 language mode**; adopting the Swift 6 language mode is optional
* iOS 13.0+, tvOS 13.0+, watchOS 6.1+

> Upgrading from `v7.x`? The public API is now explicit about the main actor. Read the [v8.0.0 migration guide](https://docs.sdk.adswizz.com/#/iOS/SDKMigrations/v8_0_0) first — for most apps the change is annotating the types that own the SDK managers with `@MainActor`.

## Dependencies

**_AdswizzSDK_** ships as a self-contained set of binary frameworks and has **no mandatory external dependency**.

Since **_AdswizzSDK_** `v7.10.0`, the old mandatory `AdswizzSDKPrivacyData.framework` dependency has been replaced by [**_AdswizzSDKPrivacyDataKit_**](https://docs.sdk.adswizz.com/#/iOS/SDKPrivacyDataKit/AdswizzSDKPrivacyDataKit) — an **optional** suite of components distributed from **this same repository**. Each component handles one Privacy-Sensitive permission, so your app only links the ones it actually uses and no unwanted permission usage description strings are forced into your `Info.plist`.

> **Recommended**
> Although the suite is optional, we strongly recommend installing the **IDFA** component. Without it, **_AdswizzSDK_** cannot access Apple's Identifier For Advertisers and therefore cannot deliver personalised ads to your audience, even when your users grant the system tracking permission.

> **Note**
> `AWSCore.framework` is an optional dependency, required only if you integrate **_AdswizzSDKPinpointAnalytics_**. See the [AdswizzSDKPinpointAnalytics documentation](https://docs.sdk.adswizz.com/#/iOS/SDKPinpointAnalytics/IntegratingAdswizzSDKPinpointAnalytics) and the [7.8.0 migration guide](https://docs.sdk.adswizz.com/#/iOS/SDKMigrations/v7_8_0).

## Installation

**_AdswizzSDK_** is distributed from this public repository, so **no access token or authentication is required** for any of the supported channels.

Use one and only one of these methods. Importing the SDK in multiple ways loads duplicate copies into your project and causes compiler/linker errors.

- [Swift Package Manager](#swift-package-manager)
- [CocoaPods](#cocoapods)
- [Carthage](#carthage)
- [Manually](#manually)

### Swift Package Manager

1. In Xcode, select File > Add Package Dependencies..., or select your project in the "Project Navigator" panel, open the "Package Dependencies" tab and click "+".

2. Enter the repository URL:
```ruby
https://github.com/adswizz/ad-sdk-ios
```

3. For the dependency rule, choose `Up to Next Major Version`.

4. Select the products to add to your target. Always select **_AdswizzSDK_**. The rest are optional: **_AdswizzWatchSDK_** and **_AdswizzSDKPinpointAnalytics_**, plus any **_AdswizzSDKPrivacyData*_** permission components your app needs — for example **_AdswizzSDKPrivacyDataIDFA_** for tracking, or **_AdswizzSDKPrivacyDataMicrophone_** and **_AdswizzSDKPrivacyDataSpeech_** for interactive audio ad formats.

> `AdswizzSDKPrivacyDataCore` is not a selectable product — it is linked automatically as a dependency of any permission component you select.

If you also install **_AdswizzSDKPinpointAnalytics_**, add the [AWSCore Swift Package](https://github.com/aws-amplify/aws-sdk-ios) as well.

Hitting package resolution errors? See the [SPM troubleshooting guide](https://docs.sdk.adswizz.com/#/iOS/SDKiOS/GetStarted).

### CocoaPods

CocoaPods 1.13.0 or newer is recommended. Add to your Podfile:

```ruby
pod 'AdswizzSDK', :git => "https://github.com/adswizz/ad-sdk-ios.git"
```

Then add any optional components you need, from the same repository:

```ruby
pod 'AdswizzSDKPrivacyDataKit/IDFA',    :git => "https://github.com/adswizz/ad-sdk-ios.git"
pod 'AdswizzWatchSDK',                  :git => "https://github.com/adswizz/ad-sdk-ios.git"
pod 'AdswizzSDKPinpointAnalytics',      :git => "https://github.com/adswizz/ad-sdk-ios.git"
```

Run `pod install`. Dependencies resolve automatically.

The available **_AdswizzSDKPrivacyDataKit_** subspecs are `IDFA`, `Photos`, `Microphone`, `Speech`, `Location`, `Calendar`, `Motion`, `Contacts` and `Camera`. Only add the ones matching permissions your app actually uses, to avoid issues during App Store review. See [Integrating AdswizzSDKPrivacyDataKit](https://docs.sdk.adswizz.com/#/iOS/SDKPrivacyDataKit/IntegratingAdswizzSDKPrivacyDataKit).

### Carthage

Carthage 0.38.0 or newer is recommended.

#### Step 1: Cartfile

```ruby
binary "https://raw.githubusercontent.com/adswizz/ad-sdk-ios/master/AdswizzSDK.json"
github "https://github.com/adswizz/ad-sdk-ios"
github "aws-amplify/aws-sdk-ios"
```

> **Note**
> The `aws-amplify/aws-sdk-ios` line is only needed if you also integrate **_AdswizzSDKPinpointAnalytics_**.

#### Step 2: Run

```ruby
carthage update --use-xcframeworks
```

Carthage creates a `Build` folder containing the **_AdswizzSDK_** binaries.

#### Step 3: Project setup

Carthage requires frameworks to be linked manually. Drag `AdswizzSDK.xcframework` and `AdswizzSDKCore.xcframework` into your application's `Frameworks` group, and make sure both are linked and embedded.

To use any **_AdswizzSDKPrivacyDataKit_** component, also link and embed `AdswizzSDKPrivacyDataCore.xcframework` from the same `Build` folder, along with the permission components your app needs.

### Manually

Download the archive for the version you want from the [releases section](https://github.com/adswizz/ad-sdk-ios/releases), or clone this repository at the corresponding tag.

The `Framework` folder contains:

```
AdswizzSDK.xcframework
AdswizzSDKCore.xcframework
AdswizzSDKPrivacyDataCore.xcframework
AdswizzWatchSDK.xcframework
AdswizzSDKPinpointAnalytics.xcframework
```

Drop `AdswizzSDK.xcframework` and `AdswizzSDKCore.xcframework` into your project's `Frameworks` group and make sure both appear under "Embedded Binaries" in your target.

Optionally, link and embed `AdswizzSDKPrivacyDataCore.xcframework`, then add the permission components you need from the `AdswizzSDKPrivacyDataKit` folder by dragging the appropriate `.xcodeproj` files into your workspace or project.

## Configuration

After adding the SDK you need to supply an **_installationId_** and a **_playerId_** — both provided by your AdsWizz Integration Manager — either in your `Info.plist` (`AdswizzAdSDKInstallationId`, `AdswizzAdSDKPlayerId`) or programmatically via `AdswizzSDKConfig`. See [Get started](https://docs.sdk.adswizz.com/#/iOS/SDKiOS/GetStarted) for the full setup, including the optional `AdswizzAdSDKAppStoreId` and the permission usage description keys.

## Documentation

Full documentation is available at [docs.sdk.adswizz.com](https://docs.sdk.adswizz.com/#/Main/iOSAdswizzSDK):

* [Documentation home](https://docs.sdk.adswizz.com/#/iOS/README)
* [Before you start](https://docs.sdk.adswizz.com/#/iOS/SDKiOS/BeforeYouStart)
* [Get started](https://docs.sdk.adswizz.com/#/iOS/SDKiOS/GetStarted)
* [Debugging](https://docs.sdk.adswizz.com/#/iOS/SDKiOS/Debugging)
* [Sample projects](https://docs.sdk.adswizz.com/#/iOS/SDKiOS/SampleProjects)
* [Changelog](https://docs.sdk.adswizz.com/#/iOS/CHANGELOG)

Runnable examples live in the [`Samples`](Samples) folder of this repository. Open `Samples/Examples.xcworkspace` after running `pod install`.

## Releases

Check out the [releases section](https://github.com/adswizz/ad-sdk-ios/releases) for downloadable zips of the SDK, and the [changelog](https://docs.sdk.adswizz.com/#/iOS/CHANGELOG) for what changed in each version.

> **Note**
> Release tags use plain semantic versioning (for example `7.14.5`). Versions released before `7.14.0` use the older `release/x.y.z` tag format.

## License

Copyright © 2026 AdsWizz Inc. All rights reserved.

The contents of this repository are proprietary materials of AdsWizz Inc. Public access does not grant any license to use, reproduce, modify or distribute them. Any use is permitted only as expressly authorized by a separate written agreement with AdsWizz Inc. See the [LICENSE](LICENSE) file for details.
