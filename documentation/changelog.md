[<img src="../img/adswizz_logo.png" alt="AdsWizz" style="width:30%;">](https://www.adswizz.com)
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [7.13.3] - 2025-11-26
### Changed
- Foundation URLs:
    - For apps linked on or after iOS 17, invalid characters (such as spaces) in URLs are automatically percent- and IDNA-encoded to help create a valid URL according to [RFC 3986](https://www.ietf.org/rfc/rfc3986.txt)

### Fixed
- `AdCompanionView`:
    - Improve the companion view's content transition between multiple ads each with its own associated companion resource
- Podcasts
    - Correct a rare case when downloading a podcast would be out-of-sync with its VAST file

## [7.13.2] - 2025-10-13
### Changed
- `AdCompanionView`:
    - Updated `adCompanionView(_ adCompanionView: AdCompanionView, didFailToDisplay error: Error)` **_AdCompanionView_** delegate to notify only fatal errors that could prevent content display indefinitely.
- `AdPlayer`:
    - Deprecated `timedMetadata` property from **_AdPlayer_** which was previously observed for metadata changes, migrated to `AVPlayerItemMetadataOutput` with delegate-driven updates via `metadataOutput(_:didOutputTimedMetadataGroups:from:)`.

## [7.13.1] - 2025-09-12
### Added
- `AdData`:
    - New public properties in **_AdData_** protocol:
        - `adTitle` returns the VAST title of the ad.
        - `adDescription` returns the VAST description of the ad. May be missing.

## [7.13.0] - 2025-08-28
### Added
- `AdCompanionView`:
    - New public method in **_AdCompanionView_**:
        - `activateIfNeeded()` forces the `AdCompanionView` instance to recheck its internal visibility state if it is not already "active". Please refer to the [Companion view best practices](iOS/SDKiOS/CompanionBanner#companion-best-practices) section from the [AdCompanionView docs](iOS/SDKiOS/CompanionBanner).

### Fixed
- Foundation URLs:
    - Improve internal validation for Foundation URLs by conforming to the [latest URL Standard](https://url.spec.whatwg.org/)
- `AdCompanionView`:
    - Improve the internal `WkWebView` content sizing
- Samples
    - UI corrections for the `BasicAdRequestExample` project

## [7.12.5] - 2025-07-29
### Added
- `AdData`:
    - New public property in **_AdData_**:
        - `selectedCompanion` to access the VAST [Companion data](iOS/SDKiOS/CompanionBanner#companion-data) model properties such as ideal `width` and `height` that determine the intended aspect ratio for the associated resource.

### Fixed
- HLS interstitials:
    - Fix behavior for the internal interstitial player in response to `skipAd()` and `reset()` on the **_AdManager_** instance set up with an **_AdInterstitialEventMonitor_**.
    - Resolve a potential crash on ad playback error when using the internal interstitial player
    - Improve URL matching when internal interstitial player observes the AVQueuePlayer's backing items

## [7.12.4] - 2025-06-11
### Changed
- `AdManager` analytics:
    - The following analytics events are now triggered in response to the **_AdEvent_** updates received from either the internal (integrated) or external player, rather than on methods such as `play()` or `pause()`:
        - ad-manager-play
        - ad-manager-pause

### Fixed
- `AdManager` pre-caching:
    - Service release that clears the old asset before attempting to play the ad break that previously failed e.g due to network conditions while downloading the asset.
- Samples:
    - Minor UI corrections for the `BasicAdStreamExample` project

## [7.12.3] - 2025-05-27
### Added
- `AdswizzAdStreamManager`:
    - New public method in **_AdswizzAdStreamManager_**:
        - `static decorate(_ url: URL) throws -> URL` enables you to augument your stream `url` with AdsWizz specific query items

### Fixed
- `AdswizzAdStreamManager`:
    - Service release that fixes the ad break re-entry after skip ad when using external player.

## [7.12.2] - 2025-05-12
### Fixed
- `AdswizzAdStreamManager`:
    - Service release that fixes a rare crash when playing a stream URL with external player due to unexpected `playerStatus` state sequence. Please refer to the complete [state machine diagram](iOS/SDKiOS/ExternalPlayer#playerstatus) for your player to implement.

## [7.12.1] - 2025-05-07
### Added
- Samples:
    - Improve the [BasicDVRRequestExample](iOS/SDKiOS/SampleProjects#basicdvrrequestexample) sample project to showcase external player support for DVR-enabled streams.

### Changed
- `AdswizzAdStreamManager`:
    - public **_DVRMetadata_** data class has been replaced by the **_AdStreamDVRMetadata_** protocol as per the **_AdswizzSDK_** naming conventions
    - public method `loadDVRMetadata(completion: ((DVRMetadata?) -> ())? = nil)` has been replaced by `requestDVRMetadata(completion: ((Result<AdStreamDVRMetadata, Error>) -> Void)? = nil)`
    - public method `cancelLoadingDVRMetadata()` has been replaced by `cancelDVRMetadataRequest()`

## [7.12.0] - 2025-03-28
### Added
- `AdswizzAdRequest` improvements:
    - New public methods in **_AdswizzAdRequest.Builder_**:
        - `with(companionZoneIds: [Int])` sets an array of *numerical* identifiers on the **_AdswizzAdRequest.Builder_** for companion zone ids. It replaces the `with(companionZones: String?)` method which is now deprecated and will be removed in a future release
        - alternatively, `with(companionZoneAliases: [String])` sets an array of *string* identifiers on the **_AdswizzAdRequest.Builder_** for companion zone aliases
        - read more on the **_AdswizzAdRequest_** configuration for [companion zones](iOS/SDKiOS/CompanionBanner#client-side-setup) setup
- Added new VAST version support in `AdswizzAdRequest`:
    - New public value in **_VASTVersion_** enum:
        - `v41` unlocks support for VAST version `4.1`, now set as the default value in **_AdswizzAdRequest_**
- `AdCompanionView` tvOS:
    - New support for [companion views with static resources](iOS/SDKTVOS/Limitations#adcompanionview) such as images. Note that `html` content remains unsupported due to `WKWebView` being unavailable on tvOS
- Swift Concurrency:
    - New public convenience methods to support async context:
        - `requestAds() async throws -> AdManager` for **_AdRequestConnection_** to [fetch an AdManager](iOS/SDKiOS/ClientSideInsertion#requesting-ads)
        - `initialize(with configuration: AdswizzSDKConfig? = nil) async throws` for **_AdswizzSDK_** to [setup the SDK](iOS/SDKiOS/GetStarted#sdk-initialization-and-setup)
- Samples:
    - Updated the [BasicTVOSExample](iOS/SDKTVOS/SampleProjects#basictvosexample) sample project to showcase companion views with static resources.

### Changed
- Deployment version:
    - The minimum deployment version for **_AdswizzSDK_** binary frameworks was bumped to iOS 13.0
- XCFramework:
    - **_AdswizzSDK_** binary frameworks are now compiled with Xcode version `16.2` (adds support for Swift version `5.10.0`)
- AdswizzAdRequest:
    - By default, **_AdswizzAdRequest_** now uses VAST version `4.1`. Ad requests can still use version 4.0 by manually setting it (using `.with(vastVersion: VASTVersion)` AdswizzAdRequest.Builder method) when configuring an **_AdswizzAdRequest_**

### Fixed
- AdswizzSDK tvOS:
    - Building **_AdswizzSDK_** binary frameworks with Xcode `16.2` fixes an issue on AppStore submission for .ipa archives that integrate **_AdswizzSDK_** for the `tvOS` platform
- Samples:
    - Improve the predefined ad request zone identifiers from Adswizz AdServer and the AIS streams for testing purposes

## [7.11.0] - 2025-02-21
### Added
- AdswizzAdRequest:
    - SDK support for requesting "shim" ads
    - New public classes **_AdswizzShimZone_** and **_AdswizzShimZone.Builder_** to create and set a "shim" zone on the **_AdswizzAdRequest_**
        - New public methods in **_AdswizzShimZone.Builder_**:
            - `with(zoneId: String)` sets the zone identifier
            - `with(zoneAlias: String)` sets the zone identifier (alternative to `zoneId`)
            - `with(maxDeadAir: TimeInterval)` sets a "dead air" tolerance to fulfill the duration requirement
            - `build()` creates an instance of **_AdswizzShimZone_**
    - New public method in **_AdswizzAdZone.Builder_**:
        - `with(zoneAlias: String)` sets the zone identifier (alternative to the existing `zoneId`)
    - New public method in **_AdswizzAdRequest.Builder_**:
        - `with(shim: AdswizzShimZone)` sets a shim zone on the **_AdswizzAdRequest.Builder_**
- AdManager:
    - SDK support for HLS interstitials livestream ad-replacement scenario
    - New public interface **_AdManagerInterstitialEventDatasource_** to be able to replace a VAST MediaFile uri and match it in the `AVPlayerItem` associated to an `AVPlayerInterstitialEvent`
        - New public optional method `func adManager(_ adManager: AdManager, interstitialMediaFileURL ad: AdData) -> URL?` to provide the SDK an alternative MediaFile uri
    - New public property in **_AdManager_** protocol:
        - `interstitialDatasource` to communicate with objects that conform to **_AdManagerInterstitialEventDatasource_**
- Integration Guide:
    - New section on [AdManagerInterstitialEventDatasource](iOS/SDKiOS/ClientSideInsertion#admanagerinterstitialeventdatasource-protocol) protocol and [AdswizzShimZone](iOS/SDKiOS/ClientSideInsertion#shim-zone) support

### Fixed
- AdswizzSDK tvOS:
    - Add missing `tvOS` as supported platform for some of the internal modules. This fixes a binary issue on AppStore submission for .ipa archives that integrate AdswizzSDK for tvOS

## [7.10.2] - 2024-12-20
### Added
- HLS interstitials:
    - Add support for native [HLS Interstitials](iOS/SDKiOS/HLSInterstitials) from `AVPlayer` driven by **_AdManager_** instances
    - New [sample project](iOS/SDKiOS/SampleProjects?id=advancedhlsinterstitialexample) which demonstrates the HLS Interstitials support

## [7.10.1] - 2024-12-12
### Added
- AdswizzSDK tvOS:
    - Add support for [AdswizzSDK tvOS](iOS/SDKTVOS/AdswizzTVOSSDK) framework

### Changed
- Client side scenario:
    - Updated stalling detection mechanism for the internal player from **_AdManager_** to consider only `timeoutIntervalBeforeStalling` values greater than or equal to 3 seconds. The mechanism now also has the capability to detect initial buffering stalling when pre-caching is disabled.
- Open Measurement SDK:
    - Service release that updates to the latest OMSDK v1.5.2 (certified by IAB)

## [7.10.0] - 2024-10-25
### Added
- AdswizzSDKPrivacyDataKit
    - Add support for [AdswizzSDKPrivacyDataKit](iOS/SDKPrivacyDataKit/AdswizzSDKPrivacyDataKit) optional framework suite
- Integration Guide:
    - New section on [AdswizzSDKPrivacyDataKit](iOS/SDKPrivacyDataKit/AdswizzSDKPrivacyDataKit) overview and how to [integrate](iOS/SDKPrivacyDataKit/IntegratingAdswizzSDKPrivacyDataKit) optional permission [components](iOS/SDKPrivacyDataKit/AdswizzSDKPrivacyDataKit#structure)
    - New guide on [How to migrate to AdswizzSDK v7.10.0+](iOS/SDKMigrations/v7_10_0.md)

### Removed
- AdswizzSDKPrivacyData mandatory dependency:
    - Removed support for **_AdswizzSDKPrivacyData.framework_**. Replaced by [AdswizzSDKPrivacyDataKit](iOS/SDKPrivacyDataKit/AdswizzSDKPrivacyDataKit)

### Changed
- Integration Guide:
    - Updated the [Get Started](iOS/SDKiOS/GetStarted) section and the [integration guide](iOS/SDKiOS/GetStarted#adding-the-sdk-to-your-xcode-project)

### Fixed
- Raw data signals:
    - Service release that fixes the internal data collectors in order to prevent crashing the application due to an asynchronous issue
- Integration Guide:
    - Improved [Companion banners best practices](iOS/SDKiOS/CompanionBanner#companion-best-practices) section when working with the [AdCompanionView](iOS/SDKiOS/CompanionBanner#adding-an-adcompanionview) component

## [7.9.3] - 2024-09-13
### Added
- Integration Guide:
    - New section on [Companion banners best practices](iOS/SDKiOS/CompanionBanner#companion-best-practices) when working with the [AdCompanionView](iOS/SDKiOS/CompanionBanner#adding-an-adcompanionview) component

### Fixed
- Analytics:
    - Service release
- Integration Guide:
    - Minor fix in the `carthage.sh` script for [Carthage integrations](iOS/SDKiOS/GetStarted#custom-carthage-run-script) when the script is executed in the `zsh` interactive shell instead of `bash` 
- Samples:
    - Updated the [BasicSwiftUIClientSideInsertion](iOS/SDKiOS/SampleProjects#basicswiftuiclientsideinsertion) sample which improves handling for UI components such as `AdCompanionView` and `AdVideoView` in a SwiftUI app

## [7.9.2] - 2024-06-28
### Added
- Dependency manager support:
    - Add Swift Package Manager support for integrating **_AdswizzSDK_** and its dependencies. For more details, please visit the [Get started](iOS/SDKiOS/GetStarted#adding-the-sdk-to-your-xcode-project) section from the Integration Guide on iOS
- VAST macros support:
    - [STOREID] VAST Macro for AppStore ID
- Integration Guide:
    - New section which describes the **_AdswizzSDK_** integration with [Swift Package Manager](iOS/SDKiOS/GetStarted#swift-package-manager)

### Fixed
- Interactive ads:
    - Service release that fixes a rare case for interactive ads to trigger their detected actions twice (calendar / e-mail)

## [7.9.1] - 2024-04-25
### Added
- Integration Guide:
    - New guide on [How to migrate to AdswizzSDK v7.9.0+](iOS/SDKMigrations/v7_9_0.md)
    - New section on [AdManager best practices](iOS/SDKiOS/ClientSideInsertion#admanager-best-practices) in the [Client Side Insertion](iOS/SDKiOS/ClientSideInsertion) scenario

### Changed
- Privacy:
    - Updated the `PrivacyInfo.xcprivacy` content for **_AdswizzSDK_** binary frameworks under privacy guidelines (`AdswizzSDK`, `AdswizzWatchSDK` and `AdswizzSDKPinpointAnalytics`)
- Integration Guide:
    - Updated the "Privacy" section on [Data Usage Policy](iOS/SDKPrivacy/DataUsagePolicy.md)

## [7.9.0] - 2024-04-10
### Added
- Privacy:
    - New support for the **Privacy Manifest**, an Apple standardized file that outlines the **_AdswizzSDK_** privacy practices. The following binary frameworks are now shipped with their own Privacy Manifest file:
        * `AdswizzSDK`
        * `AdswizzWatchSDK`
        * `AdswizzSDKPinpointAnalytics`
- Integration Guide:
    - New "Privacy" section describing the [Privacy Manifest](iOS/SDKPrivacy/PrivacyManifest.md) support, [Data Usage Policy](iOS/SDKPrivacy/DataUsagePolicy.md) and [Code Signing](iOS/SDKPrivacy/CodeSigning.md) for **_AdswizzSDK_**

### Changed
- XCframework:
    - **_AdswizzSDK_** binary frameworks are compiled with Xcode version `15.2` (adds support for Swift version `5.9.2`)
- Integration Guide:
    - Updated documentation for the new Swift supported version

## [7.8.8] - 2024-03-28
### Removed
- AdAsset:
    - public property `data` from **_AdAsset_** public protocol

### Changed
- AdAssetDelegate:
    - The `@objc optional func adAsset(_ asset: AdAsset, didFinishDownloadingData data: Data)` method signature has been changed to `@objc optional func adAssetDidFinishDownloadingData(_ asset: AdAsset)`. Hence the `data` parameter has been removed
    - The `@objc optional func adAsset(_ asset: AdAsset, didDownload data: Data, bytesDownloaded: Int64, outOf bytesExpected: Int64)` method signature has been changed to `@objc optional func adAsset(_ asset: AdAsset, didDownloadDataWith bytesDownloaded: Int64, outOf bytesExpected: Int64)`. Hence the `data` parameter has been removed

### Fixed
- AdManager pre-caching:
    - Fixed a rare crash during assets pre-caching due to memory fragmentation while downloading data slices from network
- Companion banners:
    - Fixed URL behavior on iOS 17+ which prevented companion banners to be displayed when attempting to load HTML based resources

## [7.8.7] - 2024-03-13
### Fixed
- AdManager VAST events:
    - Fixed a case where `mute`/`unmute` VAST events would be triggered outside the playing state of the internal player
- AdManager pre-caching:
    - Fixed memory leaks during assets pre-caching
- Interactive Ads:
    - Fixed scheduling local notifications for interactive ads that support this behavior
- Integration Guide:
    - Improved documentation by adding a diagram which describes the flow for an **_AdManager_** instance with pre-caching enabled

## [7.8.6] - 2024-02-23
### Added
- Client side scenario:
    - New public property in **_AdManagerSettings_** class:
        - `adCachePolicy` for passing an **_AdCachePolicyConfiguration_** instance and enable pre-caching on the **_AdManager_** for which the **_AdManagerSettings_** instance will be applied. Note that this is the recommended way to enable pre-caching for the ads creatives managed by the **_AdManager_**
    - New public properties in **_AdCachePolicyConfiguration_** class:
        - `cachePolicy` list for adding `AdCachePolicy` options
        - `timeoutIntervalForResources` for defining an optional timeout interval measured in seconds for the data requests during pre-caching. If not set, a default value will be used, please consult the documentation for Client Side Insertion scenario
        - New public class `Builder` to help create an **_AdCachePolicyConfiguration_** instance with the properties from above
- AdswizzSDK versioning:
    - New public member in **_AdswizzSDK_** shared instance: 
        - `sdkVersion` - conveniently exposes the **_AdswizzSDK_** version as string e.g "7.8.6"

### Changed
- AdManagerSettings:
    - The `addCachePolicy(_ policy: AdCachePolicy)` method is now deprecated. Please use the new `adCachePolicy` property to enable pre-caching by passing an **_AdCachePolicyConfiguration_** instance

### Fixed
- AdManager pre-caching:
    - Service release that finetunes and improves the error handling during pre-caching for ads creatives. See the `timeoutIntervalForResources` property on **_AdCachePolicyConfiguration_** class
- Integration Guide:
    - Improved documentation regarding supported ad events (such as `preparingForPlay`, `readyForPlay`, etc.) defining the lifecycle of ads managed by an **_AdManager_** instance

## [7.8.5] - 2024-01-18
### Added
- AdswizzSDKPrivacyData:
    - Update to version `1.0.7`:
        - Fixes a rare case where the internal `CLLocationManager` would enter a deadlock when accessing the `authorizationStatus` property
        - Adds support to the new calendar permissions in iOS 17
- VAST:
    - New public member in **_AdData_**: 
        - `advertiser` - exposes the VAST advertiser node (a string that provides the name of the advertiser as defined by the ad serving party)

### Changed
- AdswizzSDK versioning:
    - **_AdswizzSDK_** internal versioning changed to prevent issues introduced by the "Manage Version and Build Number" feature in XCode 13+

### Fixed
- AdswizzSDK initialization:
    - Service release that fixes the `completion` block for the **_AdswizzSDK.shared.initialize()_** initialization method not being called after an `uninitialize()` call

## [7.8.4] - 2023-12-18
### Changed
- Open Measurement SDK:
    - Service release that updates to the latest OMSDK v1.4.9

## [7.8.3] - 2023-11-20
### Added
- AdswizzSDK shared instance:
    - New public parameter for **_AdswizzSDK.shared.initialize()_** method:
        - async `completion` block for the **_AdswizzSDK_** initialization method
- General settings:
    - New consent option:
        - added support for setting `gpc` consent (Global Privacy Control) via `AdswizzSDK.shared.consent.gpc` call

### Changed
- General settings:
    - Deprecated access to set the GDPR consent, CCPA config, GPP consent and location options. Set all types of consent and location settings via more natural API e.g `AdswizzSDK.shared.consent.gdpr`, `AdswizzSDK.shared.location.accuracy`, etc
- Documentation:
    - Update `Integration Guide` with the added changes above

### Fixed
- Improvements:
    - Service release that improves the **_AdswizzSDK_** startup time (initialization) and memory footprint

## [7.8.2] - 2023-11-14
### Added
- Client side scenario:
    - New public property in **_AdManagerSettings_** class:
        - `timeoutIntervalBeforeStalling` for defining an optional timeout interval measured in seconds if the internal player should detect stalling automatically when the **_AdManager_** plays the ads. By default, this behaviour is disabled and it can be enabled by setting a non-zero value (the recommended value is 3 seconds or more)
        
- Samples:
    - New example project named `AdvancedPodcastExample` that shows how to implement a playlist model using the `AdswizzAdPodcastManager` in a structured scenario

### Changed
- Documentation:
    - Update `Integration Guide` with the added changes above

### Fixed
- Client side scenario:
    - Service release that fixes the pre-caching mechanism for ads in order to prevent a rare crash due to an asynchronous issue
- Raw data signals:
    - Service release that fixes the internal data collectors in order to prevent crashing the application due to an asynchronous issue

## [7.8.1] - 2023-08-14
### Changed
- Manage `Airplay` support:
    - Internal player (`AVPlayer` wrapper) now disables the external playback mode by internally setting `allowExternalPlayback` to `false`
### Fixed
- Raw data signals:
    - Service release that fixes the internal data collectors in order to prevent crashing the application due to an asynchronous issue

## [7.8.0] - 2023-08-03
### Added
- Analytics:
    - SDK support for AWSPinpoint service in the form of **_AdswizzSDKPinpointAnalytics.xcframework_** capable of logging and sending Analytics events to the Amazon servers
    - New public data class in **_AdswizzSDKPinpointAnalytics_** framework:
        - `AdswizzPinpointConfiguration` for configuring the AWS Pinpoint connector
    - New public properties in **_AdswizzPinpointConfiguration_** class:
        - `region` for defining an `AWSRegionType`
        - `projectId` for configuring the AWS Pinpoint service
        - `identityPoolId` for configuring the AWS Pinpoint service
        - `batchSize` for configuring the size of a single batch when packaging events to AWS servers
        - `minimumSendInterval` for configuring the time interval between sending batches of events to AWS servers
    - New public `AnalyticsConnector` implementation class in **_AdswizzSDKPinpointAnalytics_** framework:
        - `AdswizzPinpointConnector` for communication between `AdswizzSDK` and the AWS Pinpoint API
    - New public properties in **_AdswizzPinpointConnector_** class:
        - `configuration` for the AWSPinpoint connector initialization
- Documentation:
    - New section in Integration Guide to document the new **_AdswizzSDKPinpointAnalytics_** framework
    - New section in Integration Guide to document the migration process to the **_AdswizzSDK_** v7.8.0 and later
- Integration dependencies:
    - New automatic dependency for **_AdswizzSDKCore_** framework via Cocoapods and Carthage
- Samples:
    - New example project named `BasicAnalyticsExample` that shows how to implement an `AnalyticsConnector` and how to use the **_AdswizzSDKPinpointAnalytics_** framework

### Changed
- Analytics:
    - Public access to the `AnalyticsCollector` in **_AdswizzSDK_** has been removed and replaced by the following APIs:
        - `add(connector: AnalyticsConnector)` method
        - `remove(connector: AnalyticsConnector)` method (e.g `AdswizzSDK.shared.remove(connector: <AnalyticsConnector>)`)
- Integration dependencies:
    - Amazon's `AWSCore` external library dependency is no longer required to link against the **_AdswizzSDK_** framework
    - The **_AdswizzSDK_** binary is compiled and updated to link with the **_AdswizzSDKCore_** dependency

### Fixed
- Documentation:
    - Small corrections to the `Integration Guide` keeping the docs up-to-date

## [7.7.17] - 2023-06-16
### Added
- Server side scenario:
    - New public property in **_AdStreamManagerSettings_** class:
        - `automaticallySecureConnectionForAdURL` for securing internal requests from stream metadata performed by **_AdswizzAdStreamManager_**. The default value is `true`
- Podcasts:
    - New public property in **_AdPodcastManagerSettings_** class:
        - `automaticallySecureConnectionForAdURL` for securing internal requests from podcast metadata performed by **_AdswizzAdPodcastManager_**. The default value is `true`

### Changed
- Documentation:
    - Migrate the Integration Guide to the new `docs.sdk.devel.adswizz.com` platform for improved integration experience
- Carthage support:
    - Update the `carthage.sh` script to add support for custom .xcconfig file used to configure the **_AdswizzSDKPrivacyData_** permission flags

### Fixed
- Interactive Ads:
    - A rare case for voice ads that fail to start the voice detection

## [7.7.16] - 2023-04-06
### Fixed
- Interactive Ads:
    - A case for voice ads on iOS16+ that rendered the audio only through the top speaker
- Documentation:
    - Update section for React Native support (beta) in the Integration Guide
- Samples:
    - Service update

## [7.7.15] - 2023-03-09
### Added
- VAST macros support:
    - [APIFRAMEWORKS] & [OMIDPARTNER] VAST Macros for OMSDK Audibility
- Documentation:
    - New section for React Native support (beta) in the Integration Guide

### Changed
- Companion banners:
    - Removed delay when ending the display of a companion banner when the next ad in the ad pod doesn't have companion data or it is the last ad
    - Handle negative values for `extraExposureTime` setting in `AdCompanionOptions` to behave just like in the case of Double.greatestFiniteMagnitude value

## [7.7.14] - 2023-01-30
### Added
- GPP consent:
    - New public property in **_AdswizzSDK_** shared instance:
        - `gppConsent` for passing a GPP consent string (as per IAB's new GPP privacy standard)
- ZeroConfig:
    - Add support for disabling pre-caching for ad assets in a Client Side Scenario type of integration

### Changed
- Client side scenario:
    - Prevent unnecessary pre-caching for ads when playing with an external player

### Fixed
- Interactive Ads:
    - A rare case for interactive ads to trigger their detected action twice
- Ads pre-caching:
    - A rare case that would crash the AdswizzSDK during ad assets pre-caching due to a race condition
- Documentation:
    - Improved the API docs and Integration Guide

## [7.7.13] - 2022-12-20
### Added
- Interactive ads:
    - add support for VAST macro expansion when firing the tracking URLs defined in the interactivity JSON
- User-Agent support
    - add support for the custom User-Agent when fetching ads through a custom **_AdRequest_**

### Changed
- URL decorator
    - update logic on `listenerId` param to use the zero UUID format (00000000-0000-0000-0000-000000000000) when IDFA permission is not yet granted
- **_AdData_** adType
    - determine the `adType` exposed by **_AdData_** protocol by checking the MIME type from the VAST **_MediaFile(s)_**

## [7.7.12] - 2022-11-17
### Added
- AdManager protocol:
    - New public method in **_AdManager_** protocol:
        - `skipAd(with error: Error)` for more flexibility on reporting, especially for skippable ads
- Interopability with Google's PAL SDK:
    - New public methods in **_PALManagerProtocol_** to match the ProgrammaticAccessLibrary update to 2.5.2:
        - `sendPlaybackStart()` - notifies Google ad servers that a video ad did start playing
        - `sendPlaybackEnd()` - notifies Google ad servers that a video ad did finish playing

### Removed
- Interoperability with Google's PAL SDK:
    - public method `sendAdImpression()` from **_PALManagerProtocol_**

### Changed
- Interoperability with Google's PAL SDK:
    - **_AdswizzSDK_** now updated its **_PALManagerProtocol_** and it matches the `NonceManager` from ProgrammaticAccessLibrary v2.5.2
    - Note that these changes are not backwards compatible

## [7.7.11] - 2022-11-08
### Added
- User-Agent support:
    - New internal option for **_AdswizzSDK_** to use a custom User-Agent when firing ad requests and tracking URLs to AdsWizz Server (configurable via ZeroConfig). The default value for the User-Agent has the web format

### Changed
- Session Id support:
    - improved **_AdswizzSDK_** handling for the internal `sessionId` (configurable via ZeroConfig)
- Integration Guide:
    - improved structure and privacy/permissions coverage

## [7.7.10] - 2022-10-18
### Fixed
- Enable reporting for expected ads
    - add a sanity check to prevent an unlikely scenario where AdsWizz Server will respond with more ads than expected via the `maxAds` property of the 
    **_AdswizzAdZone_** object(s)

## [7.7.9] - 2022-10-14
### Added
- AppStore Id support
    - New public key in **_AdswizzSettingsKeys_**: 
        - `AdswizzAdSDKAppStoreId` - new **_AdswizzSDK_** related setting in Info.plist for providing AppStore Connect Apple ID
    - New public member in **_AdswizzSDKConfig_**: 
        - `appStoreId` - optional value for initializing **_AdswizzSDK_** with publisher's AppStore Connect Apple ID
- Enable reporting for expected ads
    - New public member in **_AdswizzAdRequest_**.**_Builder_**:
        - `enableExpectedAdsReporting` to enable **_AdManager_** reporting for expected ads

### Changed
- AppStore Id support:
    - updated **_AdswizzSDKConfig_** initializer to also pass `appStoreId` value (optional)

## [7.7.8] - 2022-09-21
### Changed
- Podcasting:
    - the ability to disable client side reporting (impressions and quartile tracking URLs)

### Fixed
- Improved all examples from Samples by refactoring the UI code to storyboards and including external player usage

## [7.7.7] - 2022-09-09
### Added
- New public member in **_AdManagerSettings_**: 
    - `preferredMaxBitrate` - another option for hinting the **_AdManager_** in the creative selection logic to compare the available `mediaFiles` and choose the one with the bitrate less than or equal to the given value

### Changed
- Server-side insertion:
    - enhanced error handling for the companion banner fetcher

### Fixed
- A rare case where the internal **_Asset_** would crash due to threading race conditions when pre-caching is enabled
- Improved API documentation for all public symbols in the **_AdswizzSDK_**

## [7.7.6] - 2022-07-21
### Added
- Voice ads: 
    - support for `notDetected` tracking URLs from `AdParameters` interactivity JSON

### Fixed
- Voice ads
    - `noSpeech` tracking URLs that wouldn't fire when the user doesn't say a word during recording
    - trigger keyword as query param when firing the `detected` tracking URLs

## [7.7.5] - 2022-05-16
### Fixed
- Integration Guide
    - Improve Companion Banner setup section
    - Update instructions on **_AdswizzSDKPrivacyData_** integration via Cocoapods (should point to the latest version - 1.0.6)
- **_AdManagerDatasource_**
    - `adManagerImpressionUrls(_ adManager: AdManager, ad: AdData) -> [URL]` no longer called on **_AdManager_** pause/resume scenario
- Podcasting
    - corrected `hasCompanion` property for podcast ad breaks
    - Remote Audio Data
        - A rare case where RAD would cause a crash when the AdswizzSDK gets initialized (if enabled via ZeroConfig)

## [7.7.4] - 2022-04-29
### Added
- New public member in **_AdData_**: 
    - `hasCompanion` - checks if the ad has any companion banner information to display (can be checked early in the succession of ad events)

### Changed
- The default Remote Audio Data `enabled` field to `false` in ZeroConfig setup

### Fixed
- Minor formatting issue in Remote Audio Data request header

## [7.7.3] - 2022-04-26
### Added
- **_AdswizzAdRequest_** support
    - New optional public parameter called **_duration_**, which sets the maximum total duration of ads to be selected, in seconds
- Podcasts support
    - New query parameter called `playLive`, with which a podcast URL is decorated when is streamed online

### Changed
- The default Remote Audio Data values in ZeroConfig setup
- The seek signature method for **_AdswizzAdPodcastManager_** changed from `func seek(to time: TimeInterval) throws` to `func seek(to time: TimeInterval, completion: @escaping () -> Void) throws` by adding a completion handler when the internal player finishes the operation

### Fixed
- Internal player volume handling
- A case where Remote Audio Data support would crash due to a threading issue with network manager usage
- Improved seek behavior in `BasicPodcastExample`

## [7.7.2] - 2022-03-31
### Added
- Podcasts support
    - Seek functionality during an ad
- `BasicAdStreamExample` sample
  - New external media player toggle that demonstrates the use of a custom player when implementing server side insertion

### Removed
- Public method `prepare(with url: URL)` from **_AdPodcastManager_** and precaching support

### Fixed
- Podcast support
    - Extra quartiles when pausing/resuming an ad
    - Playback for podcasts when failing to build an **_AdManager_** (e.g no ads from server)
    - Reading RAD metadata items used by **_AdswizzAdPodcastManager_**
    - Downloading podcasts with wrong cookie header when communicating with AIS servers
    - Audibility measurement for ads with VAST **_AdVerifications_**

## [7.7.1] - 2022-03-11
### Added
- Podcast support
    - New public method in **_AdPodcastManagerDelegate_**
        - `adPodcastManager(_ adPodcastManager: AdPodcastManager, didFailPlaying url: URL, error: Error)`

### Changed
- Delegate method `adPodcastManagerPlayer(_ adPodcastManager: AdPodcastManager, shouldSeekTo time: TimeInterval)` changed to `adPodcastManagerPlayer(_ adPodcastManager: AdPodcastManager, shouldSeekTo time: TimeInterval, completion: @escaping () -> Void)`. The implementation now requires calling the `completion` block back to the SDK when the seek operation completes
- `.allAdsCompleted` not triggered anymore by the `AdManager` handled by **_AdswizzAdPodcastManager_** since ads can be replayed due to backward seek operations

### Fixed
- Extra `start` quartile fired when the last ad is skipped in a podcast
- Impressions and quartiles not being triggered for ads that are replayed during podcast playback
- A case where collector data would crash due to threading race conditions

## [7.7.0] - 2022-02-25
### Added
- Podcast support
    - New public class **_AdPodcastManager_**
        - New public member `delegate` of type **_AdPodcastManagerDelegate_**
        - New public member `adPodcastManagerSettings` of type **_AdPodcastManagerSettings_**
        - New public method `prepare(with url: URL)`
        - New public method `play(with url: URL)`
        - New public method `stop()`
        - New public method `pause()`
        - New public method `resume()`
        - New public method `seek(to time: TimeInterval)`
    - New public class **_AdPodcastManagerSettings_**
        - New public member `player` of type **_MediaPlayerState_**
    - New public interface **_AdPodcastManagerDelegate_**
    - New public interface **_DownloadableAsset_**
        - New public member `url`
        - New public member `mimeType`
        - New public member `expectedContentLength`
        - New public member `state` of type **_DownloadableAssetState_**
        - New public member `location`
    - New public class **_AdswizzAdPodcastManager_**
        - New public class `Builder` to help create an `AdswizzAdPodcastManager` instance
        - New public member `delegate` of type **_AdPodcastManagerDownloadDelegate_**
        - New public method `startDownloadPodcast(with url: URL, to location: URL)`
        - New public method `stopDownloadPodcast(at location: URL)`
        - New public method `removePodcast(at location: URL)`
    - New public interface **_AdPodcastManagerDownloadDelegate_**
- New public members in **_AdswizzSDK_**:
    - `backgroundSessionCompletionHandler` - relates to background podcast downloads 
    - `disableRAD` - relates to Remote Audio Data for podcasts

### Changed
- Carthage integration Cartfile content by pointing to `AdswizzSDK.json` instead of `Adswizz.json` 
- OMSDK library updated to latest version 1.3.30

## [7.6.3] - 2022-01-28
### Changed
- **_AdswizzSDK_** binaries to be delivered with Xcode `12.4` (Swift version `5.3.2`) to maintain backwards compatibility

### Fixed
- `[IFA]` and `[LIMITADTRACKING]` VAST macros within a custom **_AdRequest_**


## [7.6.2] - 2022-01-14
### Added
- New public member in **_AdData_**: 
    - `pricing` - exposes the VAST pricing info on real-time bidding systems for an ad
- New public member in **_AdswizzAdRequest_**.**_Builder_**: 
    - `userConsentV2` - sets a TCF v2 string as described by IAB's Transparency and Consent Framework (TCF)

### Changed
- Switched from OMSDK static library to a static framework (.xcframework) to support running on a M1 chip simulator machine
- Modified the `AdswizzSDK.xcframework` to accommodate proper arm64 and x86 simulator slices on M1 architecture

### Fixed
- Carthage support by pointing to the correct `AdswizzSDK.json` in the Cartfile
- A case where **_NetworkManager_** would crash for older Xcode versions when detecting a 5G cellular connection
- Incorrect behavior for **_AdManager_** that would fire the **_skip_** VAST tracking events for the current ad when `reset()` is called, also correcting the `ad-manager-skip` Analytics event to only get logged when `skipAd()` gets called specifically

## [7.6.1] - 2021-11-18
### Added
- New sample project for a basic example of all AdswizzSDK UI components in a SwiftUI environment called **_BasicSwiftUIClientSideInsertion_**

### Fixed
- Carthage support
- A case where a voice interactive ad with VLT would fail to download the coupon set in the ad's interactivity
- Incorrect behavior for AdManager that wouldn't trigger the **_unmute_** VAST tracking event when the ad would already start as muted

## [7.6.0] - 2021-11-04
### Added
- DVR support for HLS streams in server-side insertion
    - New public members in **_AdswizzAdStreamManager_**:
        - **_play(with url: URL, timestamp: NSNumber)_** method related to DVR
    - New public members in **_AdStreamManager_**:
        - **_hasDVR_** reflects whether DVR is enabled or not
    - New public members in **_AdStreamManagerSettings_**:
        - **_addCapability(_ capability: AdStreamCapability)_** adds a capability for the stream manager (e.g `dvr`)
    - New public enum:
        - **_AdStreamCapability_** option relates to **_AdStreamManagerSettings_**
    - New public class **_DVRMetadata_** with public members:
        - **_start_** is the start UNIX timestamp for DVR stream
        - **_end_** is the latest UNIX timestamp for DVR stream
        - **_length_** is the length of the DVR buffer
- Generic intents (e.g generic skip action) specified at ZeroConfig level to be attached to Voice Ads interactivity
- The ability to trigger `mute` / `unmute` tracking events for **_AdManager_** internal player by listening to system volume
- Carthage support for AdswizzSDK integration (beta)

### Removed
- The default base URL endpoint from ZeroConfig for raw data collection module

### Changed
- Improved samples by displaying the SDK version and improved showcase for interactive (voice) ads

### Fixed
- Encoding clickThrough URLs as a second measure for **_AdCompanionView_** and **_AdVideoView_** instances
- Equality for **_AdVideoFriendlyObstruction_** instances by implementing the `hash` method

## [7.5.6] - 2021-08-20
### Fixed
- Missing **_adParameters_** in **_AdData_** for interactive voice ads with variable listening time

## [7.5.5] - 2021-08-13
### Changed
- Improved `BasicAdRequestExample` sample to support **_InteractiveAdManagerDelegate_** 

### Fixed
- A case where pausing and resuming the **_AdManager_** would prevent triggering the `complete` quartile

## [7.5.4] - 2021-08-09
### Changed
- Improved logs when `noSpeechPermissionGranted` is triggered via **_AdswizzSDKPrivacyData_**
- Improved `error` from `adManager(_: AdManager, didReceiveAd adData: AdData?, error: Error)` **_AdManager_** delegate by passing an Error instance for player errors instead of the generic `unknownMediaPlayerState`

### Fixed
- A syncing issue when loading companion banners with static resources (images) during app state changed and visibility toggle
- Seek detection being incorrectly triggered for pause/resume actions during an ad playback

## [7.5.3] - 2021-07-30
### Added
- New **_AdManagerDatasource_** methods to trigger custom URLs when tracking clicks in **_AdCompanionView_** and **_AdVideoView_**
    - `adManagerCompanionClickTrackingUrls(_ adManager: AdManager, ad: AdData, _ companion: Companion) -> [URL]`
    - `adManagerVideoClickTrackingUrls(_ adManager: AdManager, ad: AdData) -> [URL]`
- New Analytics event `trigger-vast-event` logged for **_notUsed_** and **_loaded_** VAST events

### Fixed
- Find and parse `adwData` value metadata in the entire raw string rather than just at the start
- Cases where the companion banner would fail to load due to being inactive and because of app state changed

## [7.5.2] - 2021-07-20
### Added
- New Analytics event `trigger-vast-error` triggered regardless of how many error trackers are fired
- Support for `playerExpand` and `playerCollapse` VAST events for video ads using **_AdVideoView_**

### Changed
- Improved companion banner requests when playing a stream during an ad break

### Fixed
- During a stream ad break, prevent companion banner requests from firing when companion metadata is missing

## [7.5.1] - 2021-07-05
### Changed
- Improved Analytics dimensions reported for audio/video ads with companion banners

## [7.5.0] - 2021-06-28
### Added
- Advanced Analytics System

## [7.4.1] - 2021-06-07
### Added
- New Analytics events such as `trigger-impression`
- New Analytics event attribute called `vastError` matching VAST error codes such as 300 - 303, 400 - 402, 202, 900

### Changed
- Improved creatives pre-caching mechanism due to major under the hood changes

### Fixed
- a case where crashes could occur during creatives pre-caching
- a rare case where `AdCompanionView` would lead to a crash during download for resources of static images

## [7.3.4] - 2021-04-29
### Fixed
- a case where crashes could occur during **_AdAsset_** precaching

## [7.4.0] - 2021-04-23
### Added
- Interoperability with Google's PAL SDK through **_PALManagerProtocol_**
- New public members in **_AdswizzSDK_**:
    - `palManager` - relates to the PAL SDK 
    - `omidPartner` - relates to the OM SDK
    - `omidPartnerVersion` - relates to the OM SDK
    - `omidVersion` - relates to the OM SDK
    - `xpaid` - populated with the AudioGraph ID value corresponding to the active listener
    - `disableDataCollection` to dynamically enable/disable data collector
- New public members in **_AdManager_**:
    - `analyticsCustomData` to dynamically set/update custom params for Analytics events
    - `ads` - exposes the array of playable ads as served from VAST
- New public members in **_AdData_**: 
    - `adParameters` - exposes the AdParamaters VAST tag for an ad
    - `extensions` -  exposes all the Extension VAST tags for an ad
    - `creativeExtensions` - exposes all the CreativeExtension VAST tags for an ad
    - `duration` - refers to the VAST duration for an ad
- New public members in **_AdAsset_**: 
    - `width` - refers to the VAST `width` component for a media file size
    - `height` - refers to the VAST `height` component for a media file size
- New **_AdAssetQuality_** option called `.auto`
- New public member in **_AdswizzAdRequest_**.**_Builder_** called `analyticsCustomData` to set custom params for Analytics events
- New public member in **_AnalyticsEvent_** called `customParams` for Host App to access the custom attributes 
- Support for custom params in **_AnalyticsEvent_** through **_AnalyticsCustomData_** protocol
- More **_AnalyticsEvent_** events have been logged during the ads lifecyle
- More attributes have been added to the **_AnalyticsEvent_**
- New public helper class called **_AdswizzSDKConfig_** to configure the `AdswizzSDK.shared` instance
- New public initialize method in the **_AdswizzSDK_** called `AdswizzSDK.shared.initialize(with configuration: AdswizzSDKConfig)` to set **_installationId_** and **_playerId_** programmatically

### Removed
- **_active_** property on **_AdCompanionView_** because it became private and is handled internally by the SDK
- **_adCount_** property on **_AdManager_** because it can be accessed directly through the `ads` property
- **_totalAdsDuration_** property on **_AdManager_** because it can be computed directly through the `ads` property

### Changed
- **_AdCompanionView_** will now render ads automatically when it becomes visible on screen. Otherwise, it stays inactive
- All error codes defined within the AdswizzSDK are now prefixed with 1000 i.e `201` became `1201`
- **_installationId_** and **_playerId_** string settings are no longer mandatory in Info.plist unless they are set through **_AdswizzSDKConfig_** when the AdswizzSDK is initialized

### Fixed
- a case where video would fail to render for an ad pod with multiple ads
- rendering for dynamic creative optimization (DCO) ads

## [7.3.3] - 2021-03-04
### Added
- Support for concatenated metadata during streaming

## [7.3.2] - 2021-02-26
### Fixed
- companion banner selection from VAST based on `preferredResourceType`
- certain companion banners with HTML resources that failed to be rendered by the SDK's internal WKWebView
- a case where interactive ads would fail to process interactivity

## [7.3.1] - 2021-01-28
### Added
- New Remote detector for interactive ads.
- New **_AdManagerDatasource_** protocol to further customize the **_AdManager_** object
- Two new properties on the **_AdManager_** object: `adCount` and `totalAdsDuration`
- New ad event, `adCompleted`, which marks the end for a single ad's lifecycle
- New `isEmpty()` helper method on **_AdData_**
- New **_AdCompanionResourceType_** enum for companion resource selection
- New `preferredCompanionResource` property for **_AdCompanionOptions_**

### Removed
- **_AdswizzSDK.framework_** dependency on **_SocketRocket.framework_**
- **_AdswizzSDK.framework_** dependency on **_SwiftProtobuf.framework_**

### Changed
- **_didFinishPlaying_** ad event not fired anymore for ads that do not start playing via **_didStartPlaying_** (i.e empty ads). This change may break certain logic handling for the **_didFinishPlaying_** ad event with the newer versions of the **_AdswizzSDK_**. One way to solve it is to rely on the newly introduced **_adCompleted_** ad event, which is guaranteed to be called when a single ad finishes its lifecycle.
- Two new enums are now public: `VastTrackingEvent` and `VastErrorCode`.
- **_AdVideoView_** automatically handles app state changed by setting the video `state` to `minimized` while the app is in background

### Fixed
- a case where an ad lifecycle could get stuck during asset pre-caching when the asset URL connection is refused or unreachable
- companion banners loading HTML (including iFrame) resources while the app is in the background

## [7.3.0] - 2020-12-22
### Added
- The AdswizzSDK now depends on **_AdswizzSDKPrivacyData framework_**, an open-source project meant to remove Privacy-Sensitive API from the AdswizzSDK binary
- Compilation switches for AdswizzSDKPrivacyData to exclude API that might require entries in the app's Info.plist: NO_SPEECH_ACCESS, NO_CONTACTS_ACCESS, NO_CALENDAR_ACCESS, NO_CAMERA_ACCESS, NO_LOCATION_ACCESS, NO_MICROPHONE_ACCESS, NO_MOTION_ACTIVITY_ACCESS
- Better targeting through access to CMMotionActivityManager. It can be deactivated through NO_MOTION_ACTIVITY_ACCESS compiler switch.
- Stopping access to location updates, motion updates, recording updates, photo access, calendar access or contacts access even if the permission was granted by the user. This will give your app the ability to decide if the AdswizzSDK can access these private data during runtime. New functions were added in the AdswizzSDK: **_permissionStatus(for type: PermissionType)_** and **_setPermissionStatus(for type: PermissionType, status: Bool)_**
- Added support for skippable ads, marked as so in VAST by the **_skipOffset_** attribute. An ad will automatically be skippable if VAST specifies a **_skipOffset_** equal to 0.
- Added **_skipOffset_** in the **_AdData_** public interface to signal after how many seconds the ad can be skipped by the user.
- New interactive format for voice with variable listening time.
- Added video ad support for both internal and external players.
- Added **_adType_** in the **_AdData_** public interface to distinguish the type of current ad.
- Added **_videoView_** in the **_AdManagerSettings_** public interface to help setup video support.
- Added **_AdVideoView_** public class to control rendering video content.
- Added an internal **_AdVideoModule_** module to handle video ads.
- Added support for video ad click trackings, marked as such in VAST by the **_VideoClicks_** node.
- Added a better way to enrich an ad after VAST parsing by resolving **_adType_** and **_playerDuration_** through **_AdDataUpdater_** helper object.
- Added a basic sample of how to setup and run video ads using an internal player.
- Added support for AdswizzAdStreamManager to precache a stream a head of playing when using the internal player, using the **_prepare(with url: URL) throws_** function.
- Added a convenient controller to support the iOS14+ IDFA permission request. The AdswizzSDK exposes **_TrackingPermissionController_**, a customizable ready-made **_UIViewController_** subclass container to be presented within the publisher's app hierarchy. This acquire the permission to access the identifier for advertisers.
- Added a basic example of how to configure and present the **_TrackingPermissionController_**.

### Changed
- Integration document for AdswizzSDK.framework to better explain how you can add the AdswizzSDKPrivacyData framework in your app, either through CococaPods or a git submodule.


## [7.2.1] - 2020-10-26
### Fixed
- Companion banner (**AdCompanionView** objects) behavior change: firing one **creativeView** tracking event per ad when displaying multiple companion banners for the same ad.
- Fixed an issue that was preventing the display of the in-app notification view for interactive ads.

## [7.2.0] - 2020-09-30
### Added
- SDK support to provide the current ad's duration and playback progress updates to the host app.
- Added **_adManager(_ adManager: AdManager, ad: AdData, didChangedPlayHead playHead: TimeInterval, adDuration duration: TimeInterval)_** in **_AdManagerDelegate_**
- SDK support to trigger pre-caching of media assets for all ads managed by the designated Ad Manager.
- Updated integration documentation.
- Updated and fixed samples.
- Added **_AdAssetQuality_** options in **_AdManagerSettings_**.
- Added **_AdCachePolicy_** options in **_AdManagerSettings_**.
- Added **_isCachedAssetsEnabled()_** as an extension helper for the **_AdManagerSettings_** class.
- Added the **_AdAsset_** protocol in the **_AdData_** public interface.
- Added an **_AdAssetState_** enum in the **_AdAsset_** public interface.
- Added the **_AdAssetDelegate_** protocol to track _asset_ progress during pre-caching.
- Added OM SDK v1.3, which enables measurement tag execution for client-side ad insertion in the **_AdswizzSDK_**.
- Added support to connect to **_AdswizzSDK_** analytics via the **_AnalyticsConnector_** procotol.
- Added an **_analytics_** property in the **_AdswizzSDK_** object.

### Changed
- Renamed the _willStartLoading_ ad event to **_preparingForPlay_**. The new naming format is *INCOMPATIBLE* with previous versions of the **_AdswizzSDK_**.
- Renamed the _didFinishLoading_ ad event to **_readyForPlay_**. The new naming format is *INCOMPATIBLE* with previous versions of the **_AdswizzSDK_**.
- Changed the way a **_mediaUrl_** is obtained from **_AdData_**.

### Removed
- Support for the **_mediaFiles_** array in **_AdData_**. It has been replaced with access to **_asset_** and its **_mediaUrl_**.

### Fixed
- Fixed "Play media file" action not being triggered if the app is not in focus while the shake is performed.
- Fixed cases when the companion banner does not preserve the aspect ratio of the image.
- Fixed a case where Voice Ads would stop detecting input for the current app session if the speech detector was started in the background.


## [7.1.3] - 2020-09-25
### Fixed
- Upon the iOS 14 release, the AdswizzSDK is able to safely collect a valid IDFA value even if  **_ATTrackingManager.trackingAuthorizationStatus_** is not yet determined (the user has not been asked for permission yet, which essentially means it behaves as pre-iOS 14). When the user explicitly denies access to the IDFA (**_ATTrackingManager.trackingAuthorizationStatus_** is denied), **_ASIdentifierManager_** will provide an invalid IDFA with `00000000-0000-0000-0000-000000000000` format and the AdswizzSDK will properly handle the restriction.

### Changed
- Code is compiled with XCode 12 (production) and Swift 5.3 support


## [7.1.2] - 2020-08-28
### Fixed
- iOS 14 compliant method to verify access and read the IDFA value. 
**N.B.: The AdsWizz SDK will not show the request for permission dialogue, as the publisher is responsible for controlling and designing the user experience for obtaining the tracking consent. We encourage you to involve your product, UX/UI and engineering teams in the process of designing the best solution. It is very important that you ensure a high opt-in rate for the Tracking permission, as strong business value (higher CPMs) is dependent on being able to read the IDFA value.**

## [7.1.2] - 2020-08-28
### Fixed
- iOS 14 compliant method to verify access and read the IDFA value. 
**N.B.: The AdsWizz SDK will not show the request for permission dialogue, as the publisher is responsible for controlling and designing the user experience for obtaining the tracking consent. We encourage you to involve your product, UX/UI and engineering teams in the process of designing the best solution. It is very important that you ensure a high opt-in rate for the Tracking permission, as strong business value (higher CPMs) is dependent on being able to read the IDFA value.**

### Changed
- Now, the AdswizzSDK is delivered as an xcframework, rather than a "fat" binary
- Code is compiled with XCode 12 beta 3 with Swift 5.3
- If you previously used AdswizzSDK.framework version 7.0.0 through 7.1.1, you need to add a "New Run Script Phase" in order to strip down the simulator part from the AdswizzSDK.framework fat binary. You can remove it now, as xcframework does all the work.

## [7.1.1] - 2020-07-03
### Fixed
- Fixed **_adEvents_** formatted JSON (maxAds and maxDuration field names) for multiple zone request query item. 

## [7.1.0] - 2020-05-08
### Added
- SDK support for WatchOS in the form of **_AdswizzWatch.framework_** capable of shake & voice detection.
- Support for AdsWizz's **_"In App notification"_** detection.
- Support for multiple zone request of ads from the AdsWizz Ad Server.
- Support for various VAST Macros: CONTENTPLAYHEAD, ADPLAYHEAD, BLOCKEDADCATEGORIES, ADCOUNT, TRANSACTIONID, ADTYPE, CLIENTUA, DEVICEUA, APPBUNDLE, VASTVERSIONS, PLAYERCAPABILITIES, PLAYERSTATE, ADSERVINGID, ERRORCODE, LIMITADTRACKING, IFA, IFATYPE.
- Support for various VAST Events: skip, error, loaded, notUsed.
- Support to list all VAST companions in **_AdData_** protocol.
- Improved integration documentation.
- Added a sample to ease the SDK integration using an external player.
- Added changelog.
- Added **_AdswizzAdZone_** class.
- Added **_with(zone: AdswizzAdZone)_** in **_AdswizzAdRequest.Builder_**
- Added **_with(zones: [AdswizzAdZone])_** in **_AdswizzAdRequest.Builder_**
- Added **_watchSession_** member in the **_AdswizzSDK_** class.
- Added **_WatchSession_** protocol.
- Added **_WatchSessionDelegate_** protocol.
- Added **_isAdswizzWatchData_** as extension for **_NSDictionary_** to inspect if data is for the AdswizzSDK.
- Added **_volume_** member in **_MediaPlayerState_**.
- Added **_capabilities_** member in **_MediaPlayerState_**.
- Added **_stateInfo_** in **_MediaPlayerState_**.
- Added **_MediaPlayerCapability_** class

### Changed
- Changed the way to create a valid **_AdswizzAdRequest_**

### Removed
- Support for single zone request of ads from the AdsWizz Ad Server.
- Removed **_with(duration: TimeInterval)_** from **_AdswizzAdRequest.Builder_**
- Removed **_with(zoneId: String)_** from **_AdswizzAdRequest.Builder_**

### Fixed
- Fixed complete quartile reporting.

## [7.0.0] - 2020-02-27

### Added
- Brand new **_AdswizzSDK_** written in **_Swift_**.
- Support for **_Objective C_**.
- Support for CCPA & GDPR consent.

### Changed
- Massive architectural changes that render the new API *INCOMPATIBLE* with previous versions of the **_AdswizzSDK_**.
