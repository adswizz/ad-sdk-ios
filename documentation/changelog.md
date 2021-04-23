# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [7.4.0] - 2021-04-23
### Added
- Interopability with Google's PAL SDK through **_PALManagerProtocol_**
- New public members in **_AdswizzSDK_**:
    - `palManager` - relates to the PAL SDK 
    - `omidPartner` - relates to the OM SDK
    - `omidPartnerVersion` - relates to the OM SDK
    - `omidVersion` - relates to the OM SDK
    - `xpaid` - populated with the AudioGraph ID value corresponding to the active listener
    - `disableDataCollection` to dynamically enable/disable data collector
- New public members in **_AdManager_**:
    - `analyticsCustomData` to dynamically set/update Analytics events's custom params
    - `ads` - exposes the array of playable ads as served from VAST
- New public members in **_AdData_**: 
    - `adParameters` - exposes the AdParamaters VAST tag for an ad
    - `extensions` -  exposes all the Extension VAST tags for an ad
    - `creativeExtensions` - exposes all the CreativeExtension VAST tags for an ad
    - `duration` - refers to the VAST duration for an ad
- New public members in **_AdAsset_**: 
    - `width` - refers to the VAST `width` component for a mediafile size
    - `height` - refers to the VAST `height` component for a mediafile size
- New **_AdAssetQuality_** option called `.auto`
- New public member in **_AdswizzAdRequest_**.**_Builder_** called `analyticsCustomData` to set Analytics events's custom params
- New public member in **_AnalyticsEvent_** called `customParams` for Host App to access the custom attributes 
- Support for custom params in **_AnalyticsEvent_** through **_AnalyticsCustomData_** protocol
- More **_AnalyticsEvent_** events have been logged during the ads lifecyle
- More attributes have been added to the **_AnalyticsEvent_**
- New public helper class called **_AdswizzSDKConfig_** to configure `AdswizzSDK.shared` instance
- New public initialize method in **_AdswizzSDK_** called `AdswizzSDK.shared.initialize(with configuration: AdswizzSDKConfig)` to set **_installationId_** and **_playerId_** programmatically

### Removed
- **_active_** property on **_AdCompanionView_** because it became private and handled internally by the SDK
- **_adCount_** property on **_AdManager_** because it can be accessed directly through the `ads` property
- **_totalAdsDuration_** property on **_AdManager_** because it can be computed directly through the `ads` property

### Changed
- **_AdCompanionView_** will now render ads automatically when it becomes visible on screen. Otherwise it stays inactive
- All error codes defined within the AdswizzSDK are now prefixed with 1000 i.e `201` became `1201`
- **_installationId_** and **_playerId_** string settings are no longer mandatory in Info.plist unless they were set through **_AdswizzSDKConfig_** when AdswizzSDK is initialized

### Fixed
- a case where would fail to render video for an ad pod with multiple ads
- rendering for dynamic creative optimization (DCO) ads

## [7.3.3] - 2021-03-04
### Added
- Support for concatenated metadata during streaming

## [7.3.2] - 2021-02-26
### Fixed
- companion banner selection from VAST based on `preferredResourceType`
- certain companion banners with html resources which failed to render by the SDK's internal WKWebView
- a case where interactive ads would fail to process interactivity

## [7.3.1] - 2021-01-28
### Added
- New Remote detector for interactive ads.
- New datasource protocol **_AdManagerDatasource_** to further customise the **_AdManager_** object
- Two new properties on the **_AdManager_** object: `adCount` and `totalAdsDuration`
- New ad event `adCompleted` which marks the end for a single ad's lifecycle
- New `isEmpty()` helper method on **_AdData_**
- New **_AdCompanionResourceType_** enum for companion resource selection
- New `preferredCompanionResource` property for **_AdCompanionOptions_**

### Removed
- **_AdswizzSDK.framework_** dependency on **_SocketRocket.framework_**
- **_AdswizzSDK.framework_** dependency on **_SwiftProtobuf.framework_**

### Changed
- **_didFinishPlaying_** ad event not fired anymore for ads which do not start playing via **_didStartPlaying_** (i.e empty ads). This change may break certain logic handling for the **_didFinishPlaying_** ad event with the newer versions of **_AdswizzSDK_**. One way to solve it would be to rely on the newly introduced **_adCompleted_** ad event which is guaranteed to be called when a a single ad finishes its lifecycle.
- Two new enums are now public: `VastTrackingEvent` and `VastErrorCode`.
- **_AdVideoView_** automatically handles app state changed by setting the video `state` to `minimized` while the app is in background

### Fixed
- a case where an ad lifecycle could get stuck during asset pre-caching when the asset url connection is refused or unreachable
- companion banners loading html (including iFrames) resources while the app is in background

## [7.3.0] - 2020-12-22
### Added
- AdswizzSDK now dependes on **_AdswizzSDKPrivacyData framework_**, an open source project meant to remove Privacy-Sensitive API from AdswizzSDK binary
- Compilation switches for AdswizzSDKPrivacyData to exclude API that might require entries in the app's Info.plist: NO_SPEECH_ACCESS, NO_CONTACTS_ACCESS, NO_CALENDAR_ACCESS, NO_CAMERA_ACCESS, NO_LOCATION_ACCESS, NO_MICROPHONE_ACCESS, NO_MOTION_ACTIVITY_ACCESS
- Better targeting through access to CMMotionActivityManager. It can be deactivated through NO_MOTION_ACTIVITY_ACCESS compiler switch.
- Stopping access to location updates, motion updates, recording updates, photo access, calendar access or contacts access even if the permission was granted by the user. This will give your app the ability to decide if AdswizzSDK can access these private data during runtime. New functions were added in AdswizzSDK: **_permissionStatus(for type: PermissionType)_** and **_setPermissionStatus(for type: PermissionType, status: Bool)_**
- Added support for skippable ads, marked as so in VAST by **_skipoffset_** attribute. Ad will automatically be skippable if VAST specifies a **_skipoffset_** equal to 0.
- Added **_skipOffset_** in **_AdData_** public interface to signal after how many seconds can the ad be skipped by the user.
- New interactive format for voice with variable listening time.
- Added video ads support for both internal and external players.
- Added **_adType_** in **_AdData_** public interface to distinguish the type of current ad.
- Added **_videoView_** in **_AdManagerSettings_** public interface to help setup video support.
- Added **_AdVideoView_** public class to control rendering video content.
- Added **_AdVideoModule_** internal module to handle video ads.
- Added support for video ads click trackings, marked as so in VAST by **_VideoClicks_** node.
- Better way to enrich an ad after VAST parsing by resolving **_adType_** and **_playerDuration_** through **_AdDataUpdater_** helper object.
- Added a basic sample on how to setup and run video ads using an internal player.
- Added support for AdswizzAdStreamManager to precache a stream a head of playing when using the internal player, using **_prepare(with url: URL) throws_** function.
- Added a convenient controller to support iOS14+ IDFA permission request. AdswizzSDK exposes **_TrackingPermissionController_**, a customizable ready made **_UIViewController_** subclass container to be presented within publishers's app hierarchy. Helps acquiring the permission to access the identifier for advertisers.
- Added a basic example on how to configure and present the **_TrackingPermissionController_**.

### Changed
- Integration document for AdswizzSDK.framework to better explain how you can add AdswizzSDKPrivacyData framework in your app, either through CococaPods or git submodule.


## [7.2.1] - 2020-10-26
### Fixed
- Companion banners (**AdCompanionView** objects) behaviour change: firing one **creativeView** tracking event per ad when displaying multiple companion banners for the same ad.
- Fixed an issue that was preventing the display of in app notification view for interactive ads.

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
