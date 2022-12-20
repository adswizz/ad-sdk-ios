[![AdsWizz](img/adswizz_logo.png)](https://www.adswizz.com) 
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
