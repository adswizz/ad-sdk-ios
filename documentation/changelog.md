[![AdsWizz](img/adswizz_logo.png)](https://www.adswizz.com) 
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [7.7.6] - 2022-07-21
### Added
- Voice ads: 
    - support for `notDetected` tracking urls from `AdParameters` interactivity JSON

### Fixed
- Voice ads
    - `noSpeech` tracking urls which wouldn't fire when user doesn't say a word during recording
    - trigger keyword as query param when firing the `detected` tracking urls

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
        - A rare case where RAD would cause a crash when AdswizzSDK gets initialized (if enabled via ZeroConfig)

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
    - New optional public parameter called **_duration_** which sets the maximum total duration of ads to be selected, in seconds
- Podcasts support
    - New query parameter called `playLive` with which a podcast URL is decorated when is streamed online

### Changed
- The default Remote Audio Data values in ZeroConfig setup
- The seek signature method for **_AdswizzAdPodcastManager_** changed from `func seek(to time: TimeInterval) throws` to `func seek(to time: TimeInterval, completion: @escaping () -> Void) throws` by adding a completion handler when the internal player finishes the operation

### Fixed
- Internal player volume handling
- A case where Remote Audio Data support would crash due to a threading issue with network manager usage
- Improved seek behaviour in `BasicPodcastExample`

## [7.7.2] - 2022-03-31
### Added
- Podcasts support
    - Seek functionality during an ad
- `BasicAdStreamExample` sample
  - New external media player toggle which demonstrates the use of a custom player when implementing server side insertion

### Removed
- Public method `prepare(with url: URL)` from **_AdPodcastManager_** and precaching support

### Fixed
- Podcasts support
    - Extra quartiles when pausing/resuming an ad
    - Playback for podcasts when failing to build an **_AdManager_** (e.g no ads from server)
    - Reading RAD metadata items used by **_AdswizzAdPodcastManager_**
    - Downloading podcasts with wrong cookie header when communicating with AIS servers
    - Audibility measurement for ads with VAST **_AdVerifications_**

## [7.7.1] - 2022-03-11
### Added
- Podcasts support
    - New public method in **_AdPodcastManagerDelegate_**
        - `adPodcastManager(_ adPodcastManager: AdPodcastManager, didFailPlaying url: URL, error: Error)`

### Changed
- Delegate method `adPodcastManagerPlayer(_ adPodcastManager: AdPodcastManager, shouldSeekTo time: TimeInterval)` changed to `adPodcastManagerPlayer(_ adPodcastManager: AdPodcastManager, shouldSeekTo time: TimeInterval, completion: @escaping () -> Void)`. The implementation now requires calling the `completion` block back to the SDK when seek operation completes
- `.allAdsCompleted` not triggered anymore by the `AdManager` handled by **_AdswizzAdPodcastManager_** since ads can be replayed due to backward seek operations

### Fixed
- Extra `start` quartile fired when last ad is skipped in a podcast
- Impressions and quartiles not being triggered for ads that are replayed during podcast playback
- A case where collector data would crash due to threading race conditions

## [7.7.0] - 2022-02-25
### Added
- Podcasts support
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
    - `backgroundSessionCompletionHandler` - relates to podcasts background downloads 
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
- Modified the `AdswizzSDK.xcframework` to accommodate for proper arm64 and x86 simulator slices on M1 architecture

### Fixed
- Carthage support by pointing to the correct `Adswizz.json` in the Cartfile
- A case where **_NetworkManager_** would crash for older Xcode versions when detecting a 5G cellular connection
- Incorrect behaviour for **_AdManager_** that would fire the **_skip_** VAST tracking events for current ad when `reset()` is called, also correcting the `ad-manager-skip` Analytics event to only get logged when `skipAd()` gets called specifically

## [7.6.1] - 2021-11-18
### Added
- New sample project for a basic example of all AdswizzSDK UI components in a SwiftUI environment called **_BasicSwiftUIClientSideInsertion_**

### Fixed
- Carthage support
- A case where a voice interactive ad with VLT would fail to download the coupon set in the ad's interactivity
- Incorrect behaviour for AdManager that wouldn't trigger the **_unmute_** VAST tracking event when the ad would already start as muted

## [7.6.0] - 2021-11-04
### Added
- DVR support for HLS streams in server side insertion
    - New public members in **_AdswizzAdStreamManager_**:
        - **_play(with url: URL, timestamp: NSNumber)_** method related to DVR
    - New public members in **_AdStreamManager_**:
        - **_hasDVR_** reflects if DVR is enabled or not
    - New public members in **_AdStreamManagerSettings_**:
        - **_addCapability(_ capability: AdStreamCapability)_** adds a capability for the stream manager (e.g `dvr`)
    - New public enum:
        - **_AdStreamCapability_** option relates to **_AdStreamManagerSettings_**
    - New public class **_DVRMetadata_** wih public members:
        - **_start_** is the start UNIX timestamp for DVR stream
        - **_end_** is the latest UNIX timestamp for DVR stream
        - **_length_** is the length of DVR buffer
- Generic intents (e.g generic skip action) specified at ZeroConfig level to be attached to voice ads interactivity
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
- Improved companion banner requests when playing a stream during ad break

### Fixed
- During a stream ad break, prevent companion banner requests to fire when companion metadata is missing

## [7.5.1] - 2021-07-05
### Changed
- Improved Analytics dimensions reported for audio/video ads with companion banners

## [7.5.0] - 2021-06-28
### Added
- Advanced Analytics System

## [7.4.1] - 2021-06-07
### Added
- New Analytics events such as `trigger-impression`
- New Analytics events attribute called `vastError` matching VAST error codes such as 300 - 303, 400 - 402, 202, 900

### Changed
- Improved creatives pre-caching mechanism due to major under the hood changes

### Fixed
- a case where crashes could occur during creatives pre-caching
- a rare case where `AdCompanionView` would lead to a crash during download for resources of static images

## [7.3.4] - 2021-04-29
### Fixed
- a case where it could crash during **_AdAsset_** precaching

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
