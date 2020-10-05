# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [7.2.0] - 2020-09-30
### Added
- SDK support to provide the current ad's duration and playback progress updates to Host App.
- Added **_adManager(_ adManager: AdManager, ad: AdData, didChangedPlayHead playHead: TimeInterval, adDuration duration: TimeInterval)_** in **_AdManagerDelegate_**
- SDK support to trigger pre-caching media assets for all ads managed by the designated Ad Manager.
- Updated integration documentation.
- Updated and fixed samples.
- Added **_AdAssetQuality_** options in **_AdManagerSettings_**.
- Added **_AdCachePolicy_** options in **_AdManagerSettings_**.
- Added **_isCachedAssetsEnabled()_** as extension helper for **_AdManagerSettings_** class.
- Added **_AdAsset_** protocol in **_AdData_** public interface.
- Added **_AdAssetState_** enum in **_AdAsset_** public interface.
- Added **_AdAssetDelegate_** protocol to track an _asset_ progress during pre-caching.
- Added OM SDK v1.3 which enables measurement tag execution for client-side ad insertion in **_AdswizzSDK_**.
- Added support to connect to **_AdswizzSDK_** analytics via **_AnalyticsConnector_** procotol.
- Added **_analytics_** property in **_AdswizzSDK_** object.

### Changed
- Renamed _willStartLoading_ ad event to **_preparingForPlay_**. Renders the new naming format *INCOMPATIBLE* with the previous versions of **_AdswizzSDK_**.
- Renamed _didFinishLoading_ ad event to **_readyForPlay_**. Renders the new naming format *INCOMPATIBLE* with the previous versions of **_AdswizzSDK_**.
- Changed the way a **_mediaUrl_** is obtained from **_AdData_**.

### Removed
- Support for **_mediaFiles_** array in **_AdData_**. It was replaced with access to **_asset_** and its **_mediaUrl_**.

### Fixed
- Fixed "Play media file" action not being triggered if the app is not in focus while the shake is performed.
- Fixed cases when companion banner does not preserve the aspect ratio of the image.
- Fixed a case where VoiceAds would stop detecting input for the current app session if the speech detector was started in background.


## [7.1.3] - 2020-09-25
### Fixed
- Upon iOS 14 release AdswizzSDK is able to safely collect a valid IDFA value even if  **_ATTrackingManager.trackingAuthorizationStatus_** is not yet determined (user was not asked yet for permission which essentially means it behaves as pre-iOS 14). When user explicitly denies access to IDFA (**_ATTrackingManager.trackingAuthorizationStatus_** is denied), **_ASIdentifierManager_** will provide an invalid IDFA with `00000000-0000-0000-0000-000000000000` format and AdswizzSDK will properly handle the restriction.

### Changed
- Code is compiled with XCode 12 (production) and Swift 5.3 support


## [7.1.2] - 2020-08-28
### Fixed
- iOS 14 compliant method to verify access and read the IDFA value. 
**N.B.: AdsWizz SDK will not show the request for permission dialogue, as the publisher is responsible for controlling and designing the user experience for obtaining the tracking consent. We encourage you to involve your product, UX/UI and engineering teams in the process of designing the best solution. It is very important that you ensure a high opt-in rate for the Tracking permission, as strong business value (higher CPMs) is dependent on being able to read the IDFA value.**

### Changed
- Now, AdswizzSDK is delivered as an xcframework, rather fat binary
- Code is compiled with XCode 12 beta 3 with Swift 5.3
- If you previously used AdswizzSDK.framework version 7.0.0 through 7.1.1 you need it to add a "New Run Script Phase" in order to strip down the simulator part from the AdswizzSDK.framework fat binary. You can remove it now as xcframework does all the work.

## [7.1.1] - 2020-07-03
### Fixed
- Fixed **_adEvents_** formatted JSON (maxAds and maxDuration field names) for multiple zone request query item


## [7.1.2] - 2020-08-28
### Fixed
- iOS 14 compliant method to verify access and read the IDFA value. 
**N.B.: AdsWizz SDK will not show the request for permission dialogue, as the publisher is responsible for controlling and designing the user experience for obtaining the tracking consent. We encourage you to involve your product, UX/UI and engineering teams in the process of designing the best solution. It is very important that you ensure a high opt-in rate for the Tracking permission, as strong business value (higher CPMs) is dependent on being able to read the IDFA value.**

### Changed
- Now, AdswizzSDK is delivered as an xcframework, rather fat binary
- Code is compiled with XCode 12 beta 3 with Swift 5.3
- If you previously used AdswizzSDK.framework version 7.0.0 through 7.1.1 you need it to add a "New Run Script Phase" in order to strip down the simulator part from the AdswizzSDK.framework fat binary. You can remove it now as xcframework does all the work.

## [7.1.1] - 2020-07-03
### Fixed
- Fixed **_adEvents_** formatted JSON (maxAds and maxDuration field names) for multiple zone request query item.    

## [7.1.0] - 2020-05-08
### Added
- SDK support for WatchOS in form of **_AdswizzWatch.framework_** capable of shake & voice detection.
- Support for AdsWizz's **_"In App notification"_** detection.
- Support for multiple zone request of ads from AdsWizz Ad Server.
- Support for various VAST Macros: CONTENTPLAYHEAD, ADPLAYHEAD, BLOCKEDADCATEGORIES, ADCOUNT, TRANSACTIONID, ADTYPE, CLIENTUA, DEVICEUA, APPBUNDLE, VASTVERSIONS, PLAYERCAPABILITIES, PLAYERSTATE, ADSERVINGID, ERRORCODE, LIMITADTRACKING, IFA, IFATYPE.
- Support for various VAST Events: skip, error, loaded, notUsed.
- Support to list all VAST companions in **_AdData_** protocol.
- Improved integration documentation.
- Added a sample to ease the SDK integration using an external player.
- Added changelog.
- Added **_AdswizzAdZone_** class.
- Added **_with(zone: AdswizzAdZone)_** in **_AdswizzAdRequest.Builder_**
- Added **_with(zones: [AdswizzAdZone])_** in **_AdswizzAdRequest.Builder_**
- Added **_watchSession_** member in **_AdswizzSDK_** class.
- Added **_WatchSession_** protocol.
- Added **_WatchSessionDelegate_** protocol.
- Added **_isAdswizzWatchData_** as extension for **_NSDictionary_** to inspect if data is for AdswizzSDK.
- Added **_volume_** member in **_MediaPlayerState_**.
- Added **_capabilities_** member in **_MediaPlayerState_**.
- Added **_stateInfo_** in **_MediaPlayerState_**.
- Added **_MediaPlayerCapability_** class

### Changed
- Changed the way to create a valid **_AdswizzAdRequest_**

### Removed
- Support for single zone request of ads from AdsWizz Ad Server.
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
- Massive architectural changes, that render the new API *INCOMPATIBLE* with the previous versions of **_AdswizzSDK_**.
