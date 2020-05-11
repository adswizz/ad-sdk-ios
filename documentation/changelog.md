# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
