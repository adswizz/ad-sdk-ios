# **AdswizzSDK for iOS - Integration guide**
- [Before you start](#before-you-start)
  * [What is ‘Client-Side Insertion’](#what-is-client-side-insertion)
  * [What is ‘Server-Side Insertion’](#what-is-server-side-insertion)
  * [Prerequisites for ‘Client-Side Insertion’](#prerequisites-for-client-side-insertion)
  * [Prerequisites for ‘Server-Side Insertion’](#prerequisites-for-server-side-insertion)
- [Get started](#get-started)
  * [Prerequisites](#prerequisites)
  * [Dependencies](#dependencies)
  * [Adding the SDK to your Xcode project](#adding-the-sdk-to-your-xcode-project)
  * [Changes in your Info.pList file](#changes-in-your-infoplist-file)
  * [SDK initialization and setup](#sdk-initialization-and-setup)
- [Client-Side Insertion](#client-side-insertion)
  * [Setting up your zone(s) for ad request](#setting-up-your-zone-for-ad-request)
  * [Your first ad request](#your-first-ad-request)
  * [Working with AdManager object](#working-with-admanager-object)
    + [Setup AdManager](#setup-admanager)
    + [Precaching ads in AdManager](#precaching-ads-in-admanager)
    + [Start AdManager](#start-admanager)
  * [AdManager life cycle](#admanager-life-cycle)
    + [AdManager operations](#admanager-operations)
    + [AdManager protocol](#admanager-protocol)
      - [prepare](#prepare)
      - [play](#play)
      - [pause](#pause)
      - [skipAd](#skipad)
      - [reset](#reset)
- [Server-Side Insertion](#server-side-insertion)
  * [AdswizzAdStreamManager operations](#adswizzadstreammanager-operations)
    + [play](#play-1)
    + [pause](#pause-1)
    + [resume](#resume)
    + [stop](#stop)
  * [AdStreamManagerDelegate protocol](#adstreammanagerdelegate-protocol)
- [Interactive ads](#interactive-ads)
  * [Voice enabled interactive ads](#voice-enabled-interactive-ads)
  * [Handling voice recording](#handling-voice-recording)
  * [Handling interactive ad events](#handling-interactive-ad-events)
- [Companion Banner](#companion-banner)
  * [Adding an AdCompanionView](#adding-an-adcompanionview)
  * [Setting things up](#setting-things-up)
  * [Companion events](#companion-events)
- [Debugging AdswizzSDK](#debugging-adswizzsdk)
- [Playing ads using your player](#playing-ads-using-your-player)
  * [MediaPlayerState protocol](#mediaplayerstate-protocol)
    + [currentDuration](#currentduration)
    + [currentPlayHead](#currentplayhead)
    + [metadataItem](#metadataitem)
    + [playerStatus](#playerstatus)
    + [isBufferingWhilePaused](#isbufferingwhilepaused)
    + [lastError](#lasterror)
    + [capabilities](#capabilities)
    + [stateInfo](#stateinfo)
    + [volume](#volume)
- [AdswizzSDK general settings](#adswizzsdk-general-settings)
  * [Companion banner](#companion-banner)
    + [Extra exposure time for an AdCompanionView](#extra-exposure-time-for-an-adcompanionview)
  * [Location](#location)
    + [Enable significant changes for location](#enable-significant-changes-for-location)
    + [Location accuracy](#location-accuracy)
  * [Privacy](#privacy)
    + [GDPR](#gdpr)
    + [CCPA](#ccpa)
- [AdswizzSDK Analytics](#adswizzsdk-analytics)  
- [(Optional) Prepare your application for advanced targetability capabilities](#optional-prepare-your-application-for-advanced-targetability-capabilities)
  * [Privacy implications](#privacy-implications)
  * [Technical prerequisites](#technical-prerequisites)
- [Sample projects](#sample-projects)
  * [BasicAdRequestExample](#basicadrequestexample)
  * [BasicAdRequestExampleObjC](#basicadrequestexampleobjc)
  * [BasicAdStreamExample](#basicadstreamexample)
  * [BasicAdStreamExampleObjC](#basicadstreamexampleobjc)
  * [ExternalPlayerExample](#externalplayerexample)
# **AdswizzWatchSDK for WatchOS - Integration guide**
- [AdswizzWatchSDK](#adswizzwatchsdk)
  * [What is AdswizzWatchSDK](#what-is-adswizzwatchsdk)
  * [What it does do](#what-it-does-do)
  * [What it doesn't do](#what-it-doesnt-do)
  * [Prerequisites for a successful integration](#prerequisites-for-a-successful-integration)
  * [Cases when updating 'Now Playing' information from iOS won't start the WatchOS companion app](#cases-when-updating-now-playing-information-from-ios-wont-start-the-watchos-companion-app)
- [Integrating AdswizzWatchSDK](#integrating-adswizzwatchsdk)
  * [Prerequisites](#prerequisites-1)
  * [Adding the SDK to your Xcode project](#adding-the-sdk-to-your-xcode-project-1)
  * [SDK integration](#sdk-integration)
    + [Watch Extension state](#watch-extension-state)
    + [Forwarding messages from WCSession to AdswizzWatchSDK/AdswizzSDK](#forwarding-messages-from-wcsession-to-adswizzwatchsdkadswizzsdk)
    + [Sending messages from AdswizzWatchSDK/AdswizzSDK to WCSession](#sending-messages-from-adswizzwatchsdkadswizzsdk-to-wcsession)
    + [Running your WatchOS companion app in the background](#running-your-watchos-companion-app-in-the-background)
- [Debugging AdswizzWatchSDK](#debugging-adswizzsdk-1)
- [Sample projects](#sample-projects-1)
  * [BasicAdRequestWatchExample](#basicadrequestwatchexample)
    + [Getting started](#getting-started)
    + [Running the sample](#running-the-sample)
- [Privacy implications](#privacy-implications-1)

# Before you start

This guide is addressed to the iOS Developers who want to integrate AdswizzSDK in their iOS apps. AdswizzSDK is not thread safe, so it is expected that all the calls to the SDK and any updates to the MediaPlayerState are done on the main thread. AdswizzSDK does all the heavy lifting on background queues, so that the main queue remains responsive.
You'll find below a quick overview, as more details are provided for each scenario in their respective section.

Starting with iOS 14, Apple fundamentally changed the way the Identifier For Advertisers (IDFA) value can be accessed. Part of the App Tracking Transparency framework, the process implies a 2-steps approach:
STEP1) **The integrator (host app) is responsible** for setting up a NSUserTrackingUsageDescription to display a system-permission alert request, and then call requestTrackingAuthorization(completionHandler:) to present the app-tracking authorization request to the end user.
STEP2) Provided end users will grant permission for tracking, AdsWizz SDK will employ the new framework to read the IDFA value.

**N.B.: AdsWizz SDK will not show the request for permission dialogue, as the publisher is responsible for controlling and designing the user experience for obtaining the tracking consent. We encourage you to involve your product, UX/UI and engineering teams in the process of designing the best solution. It is very important that you ensure a high opt-in rate for the Tracking permission, as strong business value (higher CPMs) is dependent on being able to read the IDFA value.**

## What is ‘Client-Side Insertion’

For client-side scenario you may use any streaming server and you are not required to use an AIS (Ads Insertion Server). 
Your app is responsible for the built-in logic to decide when to start and end an ad break by fetching ads from the ad server and playing them with your apps's audio/video capabilities.
The SDK will handle all communication during ad fetching with the ad server while being in charge with displaying companion banner and performing various event reporting (impressions & quartiles).

## What is ‘Server-Side Insertion’

For server-side scenario it is required to have an AIS (Ads Insertion Server) as a streaming server with the audio ads being automatically inserted on the server-side. The streaming server and the SDK split their responsibilities as follows:

**Streaming Server:**
*  detects ad breaks and inserts audio ads into the audio stream
*  updates metadata to make it possible for the SDK to synchronize companion banner with the audio content and to detect interactive ads

**SDK:**
*  decorates audio stream URL to increase targetability of ads
*  detects all events associated with an ad break (start, stop, change of ad)
*  retrieves, displays, synchronizes companion banner with the audio content based on metadata information
*  retrieves and process interactivity metadata information based on metadata information

## Prerequisites for ‘Client-Side Insertion’

In order to successfully integrate the ‘Client-Side Insertion’ you will need to set/provide the following information for your **_AdswizzAdRequest_** object within **_AdRequestConnection_**:
*  adServer = the name of AdServer used to fetch ads from
*  zoneId = identifier of zone used to retrieve audio/video ads from
*  companionZones = (optional) identifier of zone to retrieve creatives to be displayed by the companion banner
*  (optional) list of custom site variables used for ads selection (e.g referrer)

The following can be set as general AdswizzSDK parameters:
*  (optional) GDPR consent value
*  (optional) CCPA (U.S. privacy string) consent value
*  (optional) location accuracy
*  (optional) location enable significant changes

## Prerequisites for ‘Server-Side Insertion’

In order to succesufully integrate the ‘Server-Side Insertion’ you will need to set/provide the following information for your **_AdswizzAdStreamManager_** object:
*  adServer = the name of Adserver used to insert ads from
*  companionZones = (optional) identifier of zone to retrieve creatives to be displayed by the companion banner
*  adStreamURL = URL of audio stream (pass it to **_AdswizzAdStreamManager_**'s play() method)

The following can be set as general AdswizzSDK parameters:
*  (optional) GDPR consent value
*  (optional) CCPA (U.S. privacy string) consent value
*  (optional) location accuracy
*  (optional) location enable significant changes

# Get started

AdswizzSDK facilitates the ad lifecycle management, right from your application. 
Sensing listeners environment, it crafts the overall ad exercise for superior addressability and augmented interactivity.

On top, in a client-side insertion scenario, it retrieves the ad with its associated assets, and handles the reporting operations.<br>
In a server-side insertion scenario, it takes the pressure off your app by making the interactivity and assets easily available.


## Prerequisites

*   Xcode 12+
*   Swift 5.0+ if the integration app uses Swift or Objective-C
*   Framework binaries - either via CocoaPods or archive


## Dependencies

AdswizzSDK for iOS depends on two external libraries in order to support voice recognition in interactive voice ads, namely *Amazon’s AWSCore* and *Facebook’s SocketRocket*. *AWSCore* is a dependency used by the [AdswizzSDK Analytics](#adswizzsdk-analytics) too. <br>
It also relies on *SwiftProtobuf* to handle the serialized communication with AdsWizz cloud services. 
These dependencies are automatically added if you choose to integrate the SDK using CocoaPods. If choose the manual integration you will have to provide them at link time.


## Adding the SDK to your Xcode project

1. Using CocoaPods 

    AdswizzSDK is delivered as an xcframework, so the best way to integrate it is through Cocoapods. The recommended version for Cocoapods is 1.9.3 or newer. If you already have a pod file, you just need to add the following line:
    ```ruby
    pod 'AdswizzSDK', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git" 
    ```
    Replace **_ADSWIZZ_GITHUB_TOKEN_** with token you received from AdsWizz. You can obtain a token from your AdsWizz partner integration manager. After modifying the podfile, run `pod install`. You will be prompted to enter a username. Enter any valid email address. Don't leave this value empty or the install will fail. When prompted for password enter the token repository provided by AdsWizz. Once authorization is successful, external dependencies will be added automatically. These dependencies include Amazon’s AWSCore library, Facebook’s SocketRocket and SwiftProtobuf. Since AdswizzSDK.framework is built using BUILD_LIBRARY_FOR_DISTRIBUTION = YES, all Swift dependencies must be built the same way. As a [workaround](https://github.com/CocoaPods/CocoaPods/issues/9232), you need to add a post_install hook in your Podfile:
    ```ruby
    post_install do |installer|
     installer.pods_project.targets.each do |target|
         # propagate 'BUILD_LIBRARY_FOR_DISTRIBUTION' build setting
         if target.name == "SwiftProtobuf"
           target.build_configurations.each do |config|
               xcconfig_path = config.base_configuration_reference.real_path
               # read from xcconfig to build_settings dictionary
               build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.split(/\s*=\s*/, 2)}.flatten]
               build_settings["BUILD_LIBRARY_FOR_DISTRIBUTION"] = 'YES'
               # write build_settings dictionary to xcconfig
               File.open(xcconfig_path, "w") do |file|
                 build_settings.each{ |k, v|
                   file.write("#{k} = #{v}")
                 }
               end
           end
         end
     end
    end
    ```


2. Manual

    Unzip the AdswizzSDK archive, which contains AdswizzSDK.xcframework binary. Drop the AdswizzSDK.xcframework file in your project’s Frameworks directory. Make sure AdswizzSDK.xcframework is listed in the “Embedded Binaries” section of your target. Make sure to add AWSCore.framework, SocketRocket.framework and SwiftProtobuf.framework in your project as well. Be sure to have SwiftProtobuf.framework compiled with BUILD_LIBRARY_FOR_DISTRIBUTION = YES as AdswizzSDK.framework will need it.

## Changes in your Info.pList file

After adding AdswizzSDK.xcframework to your application, you’ll also need to add some keys in the Info.pList. Let’s split these in 2 categories:


1. Settings for the framework:
    1. Add "**_AdswizzAdSDKInstallationId_**" as a string setting. This is a unique string provided by your AdsWizz Integration Manager. This setting **is mandatory** and, if not set in your app’s Info.pList, the initialize method of the AdswizzSDK will throw an error.
    <img src="img/installationId.png" width="1000" />

    2. Add "**_AdswizzAdSDKPlayerId_**" string setting. This is a unique string provided by an AdsWizz PIM. This setting **is mandatory** and, if not set in your app’s Info.pList, the initialize method of the AdswizzSDK will throw an error.
    <img src="img/playerId.png" width="1000" />

    3. Add "**_AdswizzAdSDKAWSIdentityPoolIdRegion_**" as a string setting. This string will be provided by your AdsWizz Integration Manager and should look like this: "aws_region:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx". This setting is **optional**. Must be set only if you want to traffic voice ads.    
    <img src="img/aws.png" width="1000" />
    
2. Settings for permissions(**required**):
    1. Add **_NSCalendarsUsageDescription_** entry. There are interactive ads that, once acted upon, add events in the Calendar. For this, the SDK requires access to the Calendar.
    2. Add **_NSContactsUsageDescription_** entry. As events are added to the Calendar, the user might be interested in inviting friends along. For this, the SDK requires access to the Contacts.
    3. Add **_NSLocationWhenInUseUsageDescription_** entry. One of the best targeting criteria for ads is users’ location. The SDK only updates location when in the foreground. For this, the SDK requires access to Location - While the app is in use.
    4. Add **_NSLocationAlwaysAndWhenInUseUsageDescription_** entry. To enhance the location-based targeting capability, the SDK can leverage the location information, when the app is running in background. For this, the SDK requires access to Location - Always.
    5. Add **_NSMicrophoneUsageDescription_** entry. Interactive voice ads depend on the user being able to interact with the ad, through voice. For this, the SDK requires access to the Microphone.
    6. Add **_NSSpeechRecognitionUsageDescription_** entry. Once the user interacts with an interactive voice ad, the SDK needs to convert voice into text, in order to comprehend the command. For this, the SDK will require access to SpeechKit.
    7. Add **_NSPhotoLibraryUsageDescription_** entry. One of the actions users can perform on an interactive ad, is saving a coupon or a banner to the photo library. For this, the SDK requires access to the Photo Library.
    <img src="img/InfoPList.png" width="1000" />




## SDK initialization and setup

In order to properly integrate AdswizzSDK in your app, you first need to configure the AdswizzSDK. The recommended place to do that is in your **_AppDelegate_** class on **_didFinishLaunchingWithOptions_** function. Here is a snippet of what this might look like:


```swift
import UIKit
import AdswizzSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
......
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  do {
     try AdswizzSDK.shared.initialize()
  } catch {
     print(error)
  }
.......
}
.......
}
```


Your AdsWizz Integration Manager will provide you a unique SDK installation id which you need to add in your Info.pList under the **_AdswizzSDKInstallationId_** key. You are now ready for your first ad request in a client-side scenario, or playing a live stream in case of the server-side insertion approach.


# Client-Side Insertion


In this scenario, AdswizzSDK lets you decide when and where to request ads from an Ads Insertion Server and subsequently play those ads in your application.

## Setting up your zone(s) for ad request

Following the SDK initialization, the next step would be to create and configure one or more **_AdswizzAdZone_** objects before passing them to your **_AdswizzAdRequest_** object.

```swift
var zone: AdswizzAdZone!
do {
      zone = try AdswizzAdZone.Builder()
          .with(zoneId: "ZONEID_PROVIDED_BY_PIM")         // mandatory
          .with(maxAds: maximum_number_of_ads)            // optional
          .with(maxDuration: maximum_duration_in_seconds) // optional
          .build()
} catch {
     print(error)
}
```

_zoneId__ will be provided to you by your Adswizz Integration Manager.

Note that `maxAds` and `maxDuration` properties are completely optional. Also, if you're using a single zone to configure the **_AdswizzAdRequest_** object, these properties will have no effect, so you can skip setting them.

## Your first ad request

Once you've created and configure your **_AdswizzAdZone_** objects, you are ready to create an **_AdswizzAdRequest_** object and configure it. Consider the example below where it uses a configured zone from the previous code snippet above:

```swift
var adRequest: AdswizzAdRequest!
do {
      adRequest = try AdswizzAdRequest.Builder()
              .with(server: "SERVER_PROVIDED_BY_PIM")
              .with(zone: zone)
              .build()
} catch {
     print(error)
}
```

The _Ad server__ will be provided to you by your Adswizz Integration Manager.
If your specific use case involves dealing with multiple zones, your AdsWizz Integration Manager will provide you all the required zone ids. You will then be able to set and use multiple distinct and unique **_AdswizzAdZone_** objects. Here's an example of multiple zone request:

```swift
let zone1: AdswizzAdZone!
let zone2: AdswizzAdZone!
let zone3: AdswizzAdZone!
var adRequest: AdswizzAdRequest!
do {
      adRequest = try AdswizzAdRequest.Builder()
              .with(server: "SERVER_PROVIDED_BY_PIM")
              .with(zones: [zone1, zone2, zone3])
              .build()
} catch {
     print(error)
}
```
Please note that the order you pass the zones is important, as the AdsWizz Ad Server will take that into account during ad selection.


Moving next, you need create an **_AdRequestConnection_** object and call requestAds with the ad request object.

```swift
let adRequestConnection = AdRequestConnection(for: adRequest)
adRequestConnection.requestAds { [weak self] adManager, error in
     self?.didReceiveResponse(adManager, error)
}
```

Subsequent to this request, the SDK will return an error if the call failed or an **_AdManager_** object if the result was a success.


## Working with AdManager object

If the request to the AdsWizz Ad server was successful, the SDK will return an **_AdManager_** object which you will own. This will be the way the SDK will communicate events back to your application. 
To get this communication channel open you need to set up a delegate for the **_AdManager_** that conforms to the **_AdManagerDelegate_** protocol. 
The **_AdManager_** will call `func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent)` whenever events of interest occur in the SDK. Please consult AdEventType enum for a list of possible events from the AdswizzSDK. If an error happens in the SDK while using this object, `func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error)` will be called.

### Setup AdManager

As a first step, an **_AdManager_** needs to be set up. This will be done by creating an **_AdManagerSettings_** object and pass it to your newly created **_AdManager_** instance. In this object you can specify if you want to play the ad with the SDK’s internal player or use a player of your choice that must conform to the **_MediaPlayerState_** protocol.
Additionally, you can instruct **_AdManager_** which level of asset quality it should match from the available creatives for an ad. This can be done by setting the appropriate **_AdAssetQuality_** property on your instance of **_AdManagerSettings_**. By default the AdswizzSDK will attempt to select an ad asset which matches the **_.high_** quality.
You can fine tune it by using the other available quality levels such as **_.medium_** or **_.low_**.

**_AdManager_** is also capable of pre-caching the creatives assets for all of its ads before/while actually playing them. This is done by setting the appropriate **_AdCachePolicy_** on your instance of **_AdManagerSettings_**. By default the AdswizzSDK does not (pre-)cache the ads.

Next, you need to call the _.prepare()_ method on the **_AdManager_** object. This will buffer the ads if you decide the play them with the internal player.
Here is how it looks like.

```swift
import AdswizzSDK

class YourModelClass: AdManagerDelegate {
   var adManager: AdManager?
.....
func didReceiveResponse(_ adManager: AdManager?, _ error: Error?) {
    ......
    self.adManager = adManager   // Keep a strong reference of this object
    adManager?.delegate = self   // Get notifications from the Ad SDK
    
    let settings = AdManagerSettings()    // Not required
    //settings.assetQuality = .medium     // Optional, defaults to .high
    //settings.player = yourPlayer        // Optional
    //settings.addCachePolicy(.assets)    // Optional, by default the AdManager will not use its pre-caching capability
    adManager.adManagerSettings = settings

    adManager?.prepare()   // Start buffering the ads in the AdManager
}
......

......
func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
    switch event.event {
      case .readyForPlay:
           adManager.play() //Start playing the next ad in the AdManager
      case .didFinishPlaying:
          break // Current ad has finished playing
      case .allAdsDidFinishPlaying:
            break // All ads from the AdManager have finished
      default:
          break
    }
}
......
}
```

### Precaching ads in AdManager

Pre-caching the media (creative) assets will allow for your app to serve audio ads in poor network or possibly complete lack of network connection. This will improve user experience because an ad can play instantly or prevent buffering mid ad.
AdswizzSDK offers the capability of a caching like experience, by expanding the size of the buffer to allow for essentially buffering the entire media asset from each ad managed by **_AdManager_**.

You can access the underlaying **_asset_** property of an **_ad_** data, which provides additional information for that particular media asset. 
This **_AdAsset_** interface makes it easy to get access to the following information:
  * **_data_**: the asset's track data (byte array). Might be missing
  * **_mediaUrl_**: the selected media file uri for the asset. The result of your choice of AdAssetQuality
  * **_mimeType_**: the asset's creative type. For audio ads expect values to include, but not limited to "audio/mpeg" and "audio/aac"
  * **_expectedContentLength_**: the asset's expected data length in bytes
  * **_state_**: the asset's status. See AdAssetState for all possible states
  * **_delegate_**: asset delegate. Optional. If set it will notify your app with asset progress during loading

If you enable the **_.assets_** cache option through your **_AdManagerSettings_** instance, and after you set it on **_AdManager_** object, calling _.prepare()_ on **_AdManager_** instance will trigger the pre-caching mechanism.
To take full advantage of this behaviour you would ideally call _.prepare()_ in advance, before playing the ads with either the internal player or your own. This allows AdswizzSDK to download and store the media assets for _all_ of its ads and maximizes effectiveness. However, you are not required to adhere to this strategy.

Here is how it looks like with the pre-caching enabled.

```swift
import AdswizzSDK

class YourModelClass: AdManagerDelegate, AdAssetDelegate {
   var adManager: AdManager?
.....
func didReceiveResponse(_ adManager: AdManager?, _ error: Error?) {
    ......
    self.adManager = adManager   // Keep a strong reference of this object
    adManager?.delegate = self   // Get notifications from the Ad SDK
    
    let settings = AdManagerSettings()
    //settings.player = yourPlayer      // Optional
    settings.addCachePolicy(.assets)    // Instruct the AdManager to trigger the pre-caching mechanism
    adManager.adManagerSettings = settings

    adManager?.prepare()   // Start pre-caching the ads in the AdManager
}
......

......
func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
    switch event.event {
      case .preparingForPlay:
           event.ad?.asset.delegate = self //Optional, get notifications for this ad's asset
      case .readyForPlay:
           adManager.play() //Start playing the next ad in the AdManager
      case .didFinishPlaying:
          break // Current ad has finished playing
      case .allAdsDidFinishPlaying:
            break // All ads from the AdManager have finished
      default:
          break
    }
}
......

......
func adAsset(_ asset: AdAsset, didFinishDownloadingData data: Data) {
    //At this point the asset data is fully downloaded
    //...
}
    
func adAsset(_ asset: AdAsset, didDownload data: Data, bytesDownloaded: Int64, outOf bytesExpected: Int64) {
    //Called when a new slice of data has been downloaded for the asset.
    //Progress can be calculated as a 0...1 range e.g `bytesDownloaded` / `bytesExpected`
    //...
}
    
func adAsset(_ asset: AdAsset, downloadingFailedWith error: Error) {
    //Called when encountered an error during data's download for the asset
    //...
}
......
}
```

### Start AdManager

If you decided to use the SDK internal player, to actually start the **_AdManager_** rolling the ads you must call the _.play()_ method inside the **_AdManager_** object. 
If you provide the player, then you only need to start playing the ad in your player and the AdswizzSDK will observe the **_MediaPlayerState_** interface and sense when the ad has finished. In this case, calling **_adManager.play()_** is not necessary.

## AdManager life cycle

After requesting your first ad from the AdsWizz ad server, you are ready to play the ads from the AdManager object. Keep in mind that you might receive more than one ad from the server, but you are not required to play them all. If you decide to play multiple ads in your app, you need to listen to the events that the **_AdManager_** sends to your app and decide what is the appropriate action to take. Here is a diagram of the AdManager state. If you want the AdManager to play the ads with the internal player, follow the left diagram. If you want to use your own player, follow the diagram on the right.

<img src="img/AdManagerState.png" width="1000" />


### AdManager operations

Once presented with an **_AdManager_** object one could call different actions on it. Let’s break them down.

### AdManager protocol
#### prepare

You call this method to begin cycling through the ads in the **_AdManager_** object. If you decided to let the SDK handle the playback of the ads, this method ensures that the internal player is starting to buffer enough data so that ad playback starts smoothly. After calling this method, the first ad is beginning to load. The SDK will trigger **_preparingForPlay_** event informing your app that buffering has begun for the ad. If the SDK is playing the ad, you will also get **_readyForPlay_** event for the first ad. If you are playing the ad, you will not get this message since your player is responsible to start the buffering process.


#### play

If you decided to let the SDK play the ads you will need to call **_play_** method on **_readyForPlay_** (recommended). Calling this method while you are handling the ad playback has no effect in the SDK. You can call this method after you paused the AdManager to resume playback. AdManager will trigger a **_didStartPlaying_** event back to your app for confirmation. 

#### pause

If you decided to let the SDK play the ads, you can call **_pause_** method whenever you need to stop playing the ads in the AdManager. Calling this method while you are handling the ad playback has no effect in the SDK. AdManager will trigger a **_didPausePlaying_** event back to your app for confirmation.


#### skipAd

If you need to skip an ad, you can call this method to skip the current ad from the AdManager. This method applies even if you decided to take control of the ad playback. Your app will receive a **_didFinishPlaying_** event for the current ad, and if the AdManager has a new ad you will receive **_preparingForPlay_** for that one. If no ads are available, an **_allAdsDidFinishPlaying_** will be sent, signaling that all ads got processed in the AdManager.


#### reset

If you decided to skip all the upcoming ads in the **_AdManager_** object, you can call this method. For each ad you skip, your app will trigger **_didFinishPlaying_**, and a **_allAdsDidFinishPlaying_** event will be sent at the end. Looping through the ad again will need a call to **_prepare_** function.


# Server-Side Insertion

AdswizzSDK handles interactive ad insertions, while playing HLS or ICY live streams from Ad Insertion Servers. This is possible by reading the player's metadata for specific AdsWizz data and convert it in AdsWizz interactive formats or companion banners.
To get started, you need to create an **_AdswizzAdStreamManager_** object with a URL pointing to the ad server your Integration Manager provided you.


```swift
import AdswizzSDK

class YourModelClass: AdStreamManagerDelegate {
   var streamManager: AdswizzAdStreamManager?

func prepareForPlay() {
....
do {
    streamManager = try AdswizzAdStreamManager.Builder()
        .with(adServer: "SERVER_PROVIDED_BY_INTEGRATION_MANAGER")           //Mandatory
        .with(httpProtocol: .https)                         //Optional: http or https protocol for the ad server. If not provided https will be chosen.
        .with(companionZones: "COMPANION_PROVIDED_BY_INTEGRATION_MANAGER")  //Optional: companion zone provided by a Integration Manager
        .build()
} catch {
    print(error)
}
...
}

```
At this point the **_AdswizzAdStreamManager_** object can be configured with a companion zone that will be used in case the ad break defines a companion zone in the metadata but the reference to its location is missing in the stream metadata.
Once the stream object is constructed you need to set the delegate and decide whether or not you want to play the stream with your player or let the SDK do it for you:

```swift
streamManager?.delegate = self
```

If you decide to play the stream with your player, you need to provide a **_MediaPlayerState_** object with the following code:


```swift
let settings = AdStreamManagerSettings()
settings.player = yourPlayer
streamManager?.adStreamManagerSettings = settings
```

## AdswizzAdStreamManager operations
### play

To start playing a stream, call this function from **_AdswizzAdStreamManager_** with an URL to a valid AIS server. 
You should call this function even if you are playing the stream with your own player, because the URL will be enhanced with extra parameters that enable the delivery of interactive ads and companion banners. As a response, **_AdswizzSDK_** will call back `func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL)` with the newly formatted URL.

### pause

To pause a stream that is played by the SDK internal player, call this function. If you are using your own player this will have no effect.


### resume

To resume a stream that is played by the SDK internal player, call this function. If you are using your own player this will have no effect.


### stop

To stop a stream that is played by the SDK internal player, call this function. If you are using your own player this will have no effect.


## AdStreamManagerDelegate protocol
Notifications sent from **_AdswizzSDK_** to your app are implemented in the **_AdStreamManagerDelegate_** protocol. 

### func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL)
After calling the play function in the **_AdswizzAdStreamManager_** object, you will be called on this function with the url decorated with the extra parameters. 
Here you can instruct your player to start playing the stream, in case you have chosen to use your own player. 
If you decided to use the SDK internal player, you don't need to do anything at this step.

```swift
func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL) {
  yourPlayer.play(url)
}
```

### func adStreamManager(_ adstreamManager: AdStreamManager, stateChanged state: MediaPlayerStatus)
Whenever the SDK internal player or your own player state changes, you will get notified in this function. Use the states here to update your UI accordingly.

### func adStreamManager(_ adstreamManager: AdStreamManager, metadataChanged metadata: [AVMetadataItem])
Whenever the metadata is changed on the stream played by the SDK internal player, you will be notified here. 
If you opted to play the stream with your own player, this func won't be called.

### func adStreamManager(_ adstreamManager: AdStreamManager, adBreakStarted manager: AdManager)
When an ad break is detected in your stream, you will get a **_AdManager_** object containing the current running ad. You can handle this object the same way you did after getting it from an **_AdswizzAdRequest_**, except you are not obligated to keep a reference to the object. 
Here is how it might look in your app:

```swift
func adStreamManager(_ adstreamManager: AdStreamManager, adBreakStarted manager: AdManager) {
    //let settings = AdManagerSettings()
    //settings.player = yourAdPlayer     // optional step were you tell the AdManager that you want to play the ads
    //manager.adManagerSettings = settings
    manager?.delegate = self             // register for notification on this AdManager
    manager?.interactiveDelegate = self  // register for interactive ads notifications
}
```

During the ad break, you will get updates on the status of the ad if you implement the **_AdMangerDelegate_** protocol or the **_InteractiveAdManagerDelegate_** protocol.
When you get this **_AdManager_** object, the SDK internal player will automatically play the ad, since it is part of the stream. During the ad time, **_AdManager_** will not react to operations such as play or pause. However, you can skip the ad break or reset the whole **_AdManager_** object. Most of the times there will be only one ad in the **_AdManager_** object but you can expect other ads to be inserted from the SDK if the ad is extended. This can happen, for instance, when the listener interacts with an ad (i.e. ShakeMe), in order to listen an extension of the ad (more details on a topic).

### func adStreamManager(_ adstreamManager: AdStreamManager, adBreakEnded manager: AdManager)
When the ad break from the stream has ended you will get notified to clean up anything related to your **_AdManager_**.

```swift
func adStreamManager(_ adstreamManager: AdStreamManager, adBreakEnded manager: AdManager) {
    manager?.delegate = nil
    manager?.interactiveDelegate = nil
}
```

### func adStreamManagerWillReconnect(_ adstreamManager: AdStreamManager)
While interacting with an ad in the ad break, the stream might interrupt due to actions like skip ad or extend ad. At this time the SDK will inform you that will reconnect to the stream so the current ad will not be served again.

### func adStreamManagerPlayerShouldPause(_ adstreamManager: AdStreamManager)
When deciding to play with an external player the SDK might inform you to pause the ad playing.

### func adStreamManagerPlayerShouldResume(_ adstreamManager: AdStreamManager)
When deciding to play with an external player the SDK might inform you to resume the ad playing.

Here is a diagram of the AdswizzAdStreamManager state.

<img src="img/AdswizzAdStreamManagerState.png" width="1000" />


# Interactive ads

AdsWizz interactive ads require some permissions on your app. Please refer to the “Changes in you Info.pList” section to operate the necessary changes.


## Voice enabled interactive ads

AdsWizz SDK depends on a few external, third party libraries in order to deliver interactive voice ads (Amazon’s **AWSCore.framework** and Facebook’s **SocketRocket.framework**). 
To properly set up the dependencies, you need to provide inside your Info.pList a string key called **_AdswizzSDKAWSIdentityPoolIdRegion_** with the value received from your AdsWizz Integration Manager. Failing to add this key will reduce the ability of voice detection while the app is in the background.


## Handling voice recording

Apple recommends that your app’s UI reflect when recording started or stopped. AdswizzSDK provides a way to notify your app that recording has begun or stopped:


```swift
extension AppDelegate: AdswizzSDKDelegate {
    func configureAdswizzSDK() {
       AdswizzSDK.initialize(installationId: "YOUR_INSTALLATION_ID")
       AdswizzSDK.setDelegate(self)
    }
   
   func adswizzSDKRecordingStarted(_ adswizzSDK: AdswizzSDK) {
       // Update your UI to reflect that the SDK is recording
   }

   func adswizzSDKRecordingStopped(_ adswizzSDK: AdswizzSDK) {
       // Update your UI to reflect that the SDK is not recording anymore
   }
}
```



## Handling interactive ad events

While the **_AdMangerDelegate_** object provides a list of events through **_AdEventType_** covering the life cycle of an ad, it does not provide information on interactive ads. 
To get more insight on what is happening while an interactive ad is playing you can set the **_interactiveDelegate_** on the **_AdManager_** object. While implementing **_InteractiveAdManagerDelegate_** you will need to provide the code below to present a _PKAddPassesViewController_ in case the AdswizzSDK needs to save a coupon in the Wallet.


```swift
class YourModelClass {
......
func didReceiveResponse(_ adManager: AdManager?, _ error: Error?) {
    ......
    // Get interactive ad notifications from the SDK
    adManager?.interactiveDelegate = self
    ......
 }
......
extension YourModelClass: InteractiveAdManagerDelegate {
func interactiveAdManager(_ adManager: AdManager, shouldPresentCoupon pkpassData: Data) {
    do {
          let receivedPass = try PKPass(data: data)
          if let vc = PKAddPassesViewController(pass: receivedPass) {
               // Here you can present the view controller
            } 
    } catch {
    }
}
    
func interactiveAdManager(_ adManager: AdManager, didReceiveAdEvent event: InteractiveAdEvent) {
  switch event.event {
    case .willBeSkipped:
     // Ad will be skipped as a result of an action during interactive ad
     break
    case .skipped:
     // Ad was skipped as a result of an action during interactive ad                 
     break
    case .extended:
     // Ad was extended with a new media as a result of an action
     break
    default:
      break
    }
}
}
```


# Companion Banner

AdswizzSDK lets you configure companion banner(s) if your Integration Manager provides you a companion zone id.


## Adding an AdCompanionView

Companion views can be added from storyboard/xib when you add a view. Just specify the **_AASDKAdCompanionView_** ObjC class. You can also add the view programmatically. 
Once created, the SDK will keep track of all of your companion views and automatically fill them with ad related content as the ad is playing.


## Setting things up

When you create an **_AdswizzAdRequest_** object for the first time, you need to fill in the **_companionZones_** with the value provided by your Integration Manager.


```swift
adRequest = try AdswizzAdRequest.Builder()
              .with(server: "SERVER_PROVIDED_BY_INTEGRATION_MANAGER")
              .with(zoneId: "ZONEID_PROVIDED_BY_INTEGRATION_MANAGER")
              .with(companionZones: "COMPANION_PROVIDED_BY_INTEGRATION_MANAGER")
              .build()
```


Once the request is made, if there is any companion banner associated with the ad, it will be loaded into your **_AdCompanionView_** object.


## Companion events

You can associate a delegate to your **_AdCompanionView_** object that conforms to the **_AdCompanionViewDelegate_** protocol. You will be notified when the ad loaded the companion view, if the companion view was displayed, or if it ended the display. If there was an error while loading the companion banner, you will be notified through this delegate. Also, you can decide whether or not to override click through target URL on the companion banner. 

You can also deactivate companion view temporarily by setting the **_active_** member to false.


# Debugging AdswizzSDK

The SDK uses an internal logger called **_AdLogger_**. By default, the logging level is set to none, meaning that nothing gets logged. Should you need the SDK logging events, you can enable a different logging level; verbose is the one with the highest density, hence we do not recommend its use in production. 
You can also provide a new destination for the logger (e.g.: pipe it to your app logger). By default, the SDK dumps log events in the console.


```swift
extension AppDelegate: AdswizzSDKDelegate {
    func configureAdswizzSDK() {
      ......
      AdLogger.shared.level = .info
      AdLogger.shared.destination = self
      ......
    }
}
......
extension AppDelegate: AdLoggerDestination {
  func log(_ level: AdLogger.Level, functionName: String, fileName: String, lineNumber: Int, line: String) {
      //Pipe it to your logger
  }
}
```



# Playing ads using your player

By default, AdswizzSDK is configured to play the ad media using its internal player.
If you prefer playing the ad with your own player, you must configure the **_AdManager_** object received after an **_AdConnectionRequest_** with a new **_AdManagerSettings_** object. Here you can provide the player that must conform to the **_MediaPlayerState_** protocol. This protocol will notify the SDK that the player was changed, via KVO. You can also check the AdManager life cycle diagram (right one) to see what is expected from your player, so that the AdManger can function properly.

Here is how you set up your own player:

```swift
class YourModelClass {
    var yourPlayer: YourPlayer
......
func didReceiveResponse(_ adManager: AdManager?, _ error: Error?) {
    ......
    // Get interactive ad notifications from the SDK
    Let adManagerSettings = AdManagerSettings()
    adManagerSettings.player = yourPlayer
    adManager?.adManagerSettings = adManagerSettings
    ......
 }
......

class YourPlayer: NSObject, MediaPlayerState {
    @objc dynamic public var currentPlayhead: TimeInterval = 0
    @objc dynamic public var playerStatus = MediaPlayerStatus.initialized
    @objc dynamic public var metadataItem: [AVMetadataItem]?
    @objc public var currentDuration: TimeInterval = 0
}
```


Let’s break down the **_MediaPlayerState_** protocol.


## MediaPlayerState protocol
### currentDuration

Your player needs to report the total duration of the media to the AdswizzSDK, as soon as possible. The media duration is required to compute quartile events or progress events in the SDK. If it is **not possible** to report the media duration, then **set it to 0**. If the SDK reads 0 from currentDuration, it will rely on the data in the VAST metadata to get the file duration. If the info is missing in the VAST metadata as well, the quartile/progress events will be triggered at the end of the media player in the correct order but not when they actually happened.


### currentPlayHead

For a good reporting of the quartile/progress events, your player should update its current position throughout the entire ad duration. It is **highly recommended** that your player updates this value at an interval of **1 second**. Updating at a higher frequency (<1s) might incur performance issues. If your player skips forward or backward as the ad is playing, immediately update this member accordingly to reflect the action taken. This will affect the way quartile events are fired by the SDK.


### metadataItem

If your player can read metadata from the media that is playing, it should report it through this member. While this is not required for a client-side insertion, it is mandatory to relay this data when you are in the server-side insertion scenario.


### playerStatus

While your player is playing the ad it should update this member so that the AdswizzSDK can start monitoring the status of the ad through your player. **Failing to update** this member accordingly will render **_AdManager_** incapable of generating normal events.
You should put your player in the **_initialized_** state upon receiving the ad url from the **_AdManager_**, on **_preparingForPlay_** event in the following function:

```swift
func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent)
```


If your player cannot load the ad url, the player should report the **_failure_** state. You also need to set this state in case the error occurs during the ad playback, and the ad cannot be played anymore. 
When you set **_failure_** or **_unknown_** as the state of your player, the SDK will terminate the current ad that was sent in **_preparingForPlay_**, and inform your app that the media player state is **_unknown_**. The AdManager will move to the next ad, if available.

If your player is buffering data, you can report that to the SDK by setting the state to **_buffering_**. Once your player finishes buffering, you need to report **_bufferingFinished_**. Reporting **_buffering_** and **_bufferingFinished_** ensures that quartile/progress events are reported correctly and are not subject to network interruptions. Once your player is ready to play the ads (after buffering enough data), it can report a state of **_readyToPlay_**, meaning the player’s play method might be called. This state is optional and it resembles the AVPlayer currentItem readyToPlay status. If your player started the ad playback, set the state to **_playing_**. If you pause the playback, set the state to **_pause_**. Similarly, **Resume** will change the state to **_playing_** again. When the player has finished playing the ad, set the state to **_finished_**.

Here is a state machine for your player to implement.
<img src="img/MediaPlayerState.png" width="1000" />

### isBufferingWhilePaused

If your player continues to buffer data after it was paused, set this property to true. When you are playing a stream, this is a good way to let the SDK decide whether or not it should pick up from where it was paused or reconnect to the live stream again. 

### lastError

If your player encountered an error while playing an ad, report it in this property. This will help the SDK to better report errors back to the ad server.

### capabilities

If your player has specific capabilities (skip, mute, autoplay, autoplay when muted, fullscreen or it can display an icon), list them in this property. SDK will relay this information to the ad server and will ultimately help achieve better targetability. If you are not interested in this feature, then set this property to nil.

### stateInfo

This is a collection of IAB specific states (skipped, muted, autoplayed, fullscreen) that your player might go through. Reporting these accordingly will help the SDK relay this information to the ad server and will ultimately help achieve for better targetability. If you are not interested in this feature, then set this property to nil.

### volume

If your player can update the volume of the media, update this property with a value between 0.0 and 1.0. A value of 0.0 indicates silence; a value of 1.0 (the default) indicates full audio volume for the player instance.

# AdswizzSDK general settings

## Companion banner

### Extra exposure time for an AdCompanionView

By default, the **_AdCompanionView_** will end displaying the content after the ad finishes playing. If you need to keep the companion on the screen for a longer period of time (or indefinitely), you can configure it like this.


```swift
let adCompanionOptions = AdCompanionOptions()
adCompanionOptions.extraExposureTime = 1.2 // these are seconds.
// if you need the companion forever on the screen
// adCompanionOptions.extraExposureTime = .greatestFiniteMagnitude
AdswizzSDK.setAdCompanionOptions(adCompanionOptions)
```

## Location

### Enable significant changes for location

By default, **_AdswizzSDK_** will collect location updates using _startUpdatingLocation API_ from _CLLocationManager_, meaning this option is set to **_false_**. If you prefer to limit the location updates only to those significant changes, set this property to **_true_**.

```swift
AdswizzSDK.shared.enableLocationSignificantChanges = true
```

### Location accuracy
By default, **_AdswizzSDK_** location accuracy is set to the nearest kilometer. You can update this to a new _CLLocationAccuracy_ value.

```swift
AdswizzSDK.shared.locationAccuracy = kCLLocationAccuracyBest
```

## Privacy

### GDPR

AdsWizz services are GDPR compliant. As a result, **_AdswizzSDK_** will decorate urls that connect to AdsWizz services accordingly to reflect the desired GDPR user consent. To modify the GDPR consent you need to configure it like this:

```swift
AdswizzSDK.shared.gdprConsent = <Desired_GDPR_Consent>
```

If not configured, the default value for GDPR consent in **_AdswizzSDK_** will be  **_notApplicable_**. Other possible values are:
  * **_notAsked_**: the user was not asked yet about GDPR consent
  * **_granted_**: the user has granted access
  * **_denied_**: the user has denied access

### CCPA

With the introduction of CCPA in US, **_AdswizzSDK_** gives you the possibility to forward the user consent accordingly.

```swift
AdswizzSDK.shared.ccpaConfig = AdswizzCCPAConfig.Builder()
                                                  .with(explicitNotice: <Desired_CCPA_Consent>)
                                                  .with(optOut: <Desired_CCPA_Consent>)
                                                  .with(lspa: <Desired_CCPA_Consent>)
                                                  .build()

```

The default value for **_explicitNotice_**, **_optOut_** and **_lspa_** is **_notApplicable_**. Other possibile values are **_yes_** and **_no_**.

# AdswizzSDK Analytics

**_AdswizzSDK_** framework collects and exposes information on SDK's events that occur during its lifecycle. It was built to log different event types (informative and errors) that cover both integration robustness and ad lifecycle management in both client-side and server-side scenarios.
To enable integrators complement their specific app analytics systems (e.g. Firebase, Mixpanel etc) with AdsWizz SDK internal events, the **_AdswizzSDK_** framework provides you with the ability to receive all the analytics events from the SDK and forward them to your own ingestion pipelines by implementing **_AnalyticsConnector_** protocol. 
If you want to learn more about the types of events you can listen and use, please reach out to your Integration Manager at AdsWizz.

AdsWizz may also use this mechanism to collect and analyze SDK performance metrics in order to identify integration specific issues that might affect capacity or impressions/opportunities ratio.

```swift
class YourAnalyticsConnector: AnalyticsConnector {
  func log(_ event: AnalyticsEvent, _ timestamp: Date) {
      //Store or send this event to your desired platform
      //This will be called on a background queue    
  }

  func send(forced: Bool) {
      //Get's called when the SDK uninitialize. There might be other times in the future were this gets called.
      //If forced is true you should be flushing the stored events ASAP. If it is false you can send your events whenever you want.
      //This will be called on a background queue    
  }
}
```

Possibile events of interest for you might be those with the level set to **_error_**.

# (Optional) Prepare your application for advanced targetability capabilities

## Privacy implications

Please be advised that if you choose to enable the Raw Data Signal Collection, you will have to inform your customers that your application handles and processes personal anonymized data. <br>
**We highly encourage you to loop your product and legal teams in the process of defining the best way to reflect this in your application’s Privacy Policy.**

---------------------------------------------------------------------------------------------------------------------------------------------------
| Data collected for <br>**_Device Targeting_** | Data collected for <br>**_Contextual Targeting_** | Data collected for <br>**_User Targeting_**|
|:-----------------|:---------------------|:--------------|
| * device name and locale <br>* screen brightness level<br>* audio volume level<br>* battery level and status (charging/not charging)<br>* bundle id<br>* operating system version and name | * bluetooth devices (currently connected and history)<br>* WiFi Status (true/false) and WiFi network name / SSID (if connected)<br>* network carrier name and country<br>* accelerometer, GPS and gyroscope data<br>* headphone jack status (plugged/unplugged)<br>* time zone information (in GMT format)<br>* daylight saving time status (true/false) | * idfa (identifierForAdvertising) status (enabled/disabled) and ID (if enabled) |


## Technical prerequisites

AdswizzSDK framework can provide several device information using a data collector module. As of iOS 13, WiFi data can only be retrieved if the app entitlements contains the `Access Wi-Fi Information` capability.
In order to set it, go to your app's target, select Signing & Capabilities and add `Access Wi-Fi Information` capability by tapping the "+" button above.

# Sample projects

Best way to see the AdswizzSDK in action is by studying the example projects included in the `/Samples` folder. Download the `/Samples` folder using the below `git` command:
```properties
$ git clone https://github.com/adswizz/ad-sdk-ios.git
Username: adswizz-sdk
Password: your_access_token (provided by AdsWizz)
 ```

The examples are structured as separate projects in the _**Examples.workspace**_. Note that the samples workspace uses Cocoapods to install AdswizzSDK and necessary dependencies. To succesufully build and run the samples you first need to run a `pod install` to make sure all the neccessary dependencies are downloaded and resolved properly.
Next, open _**Examples.workspace**_ and run each sample individually by selecting the aproppriate target and click 'Run' in XCode.

## BasicAdRequestExample

This sample demonstrates a basic client-side insertion scenario by showing how to create and customize an _**AdswizzAdRequest**_. It shows how to use it to create an _**AdRequestConnection**_ and finally request ads. Next, it demonstrates basic usage of an instance of _**AdManager**_ once it is obtained from the SDK. It also creates and displays an _**AdCompanionView**_ while playing ad(s).
The sample attempts to simulate an app which plays its normal content and ocassionaly requests ads, pauses content, plays ads and finally resumes to normal content again. 

## BasicAdRequestExampleObjC

The same sample from above fully written in Objective-C. It demonstrates how even though AdswizzSDK is a Swift framework, it can still be used in an Objective-C project.

## BasicAdStreamExample

This sample demonstrates a basic server-side insertion scenario by showing how to create and customize an _**AdswizzAdStreamManager**_. It shows how to play/stop/pause/resume a live stream. It also creates and displays an _**AdCompanionView**_ during ad break(s).

## BasicAdStreamExampleObjC

The same sample from above fully written in Objective-C.

## ExternalPlayerExample

This sample demonstrates how to implement your external player using _**MediaPlayerState**_ protocol in order for **_AdswizzSDK_** to properly work. Also, this sample shows how you could debug events in the SDK by using _**AdLogger**_ with a verbose level.


# AdswizzWatchSDK

This guide is for the iOS developers who want to integrate **_AdswizzWatchSDK_** in their WatchOS companion apps, in order to extend the audio ad experience and interactivity on these devices.
You will find below a quick overview. More details will be provided for each scenario in their respective section.

## What is AdswizzWatchSDK?
**_AdswizzWatchSDK_** is an extension of the **_AdswizzSDK_**, specifically built for WatchOS (6.0+) companion apps that will enable you to use AdsWizz interactive ads on the listener's watch. **_AdswizzWatchSDK_** is dependent on **_AdswizzSDK_** in order to work properly.

## What it does do
**_AdswizzWatchSDK_** will enhance **_AdswizzSDK_** capabilities to deliver rich audio ads and engage with listeners in a context relevant, non-intrusive manner. Thus, **_AdswizzWatchSDK_** relies on a good integration of **_AdswizzSDK_** version 7.0 or above.
If, for example **_AdswizzSDK_** will have to play a shake-me ad on the phone it will also sense 'shake-me' events on the watch using **_AdswizzWatchSDK_**.
If the communication with the watch is viable, **_AdswizzWatchSDK_** will also collect some data from the listener to improve the targeting capabilities. Information collected on the watch will be listed below.

## What it doesn't do
**_AdswizzWatchSDK_** can't function without **_AdswizzSDK_**. It can't request ads from an ad server nor is it able to play media files. It won't make any network requests and all its communication is with **_AdswizzSDK_**. It is important to note that **_AdswizzWatchSDK_** is just an extension of **_AdswizzSDK_**.

## Prerequisites for a successful integration
In order for **_AdswizzSDK_** to use the **_AdswizzWatchSDK_** on the listener's watch, you need to make sure that your iOS app automatically opens the WatchOS companion app before the ad break starts. To do that, your iOS app needs to update the [Now Playing](https://developer.apple.com/documentation/mediaplayer/becoming_a_now_playable_app) information. When updating Now Playing in the iOS app, your WatchOS companion app will be automatically started. To recap, here's a list of things to keep in mind when integrating **_AdswizzWatchSDK_**:
* make sure your app is compliant with [Now Playing](https://developer.apple.com/documentation/mediaplayer/becoming_a_now_playable_app)
* make sure you update Now Playing information every time an ad is about to be played. Ideally, you can sync it with the **_preparingForPlay_** event you receive with the **_AdManager_** object. This will increase the probability that your WatchOS companion app will start on the watch.
* make sure your companion app has not opted out for [Auto-launch Audio App](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/watchOSKeys.html)

## Cases when updating 'Now Playing' information from iOS won't start the WatchOS companion app
* If the user has launched another app on his watch and this is in the foreground, WatchOS will not bring in foreground the corresponding WatchOS companion app even if the iOS app updated the 'Now Playing' information.
* User has set “Auto-Launch Audio Apps” to false on WatchOS settings (Settings/General/Wake Screen).

# Integrating AdswizzWatchSDK
## Prerequisites

*   Xcode 10+
*   Swift 5.0+ if the integration app uses Swift, or Objective-C
*   Framework binaries - via CocoaPods

## Adding the SDK to your Xcode project
**_AdswizzWatchSDK_** is delivered as an xcframework, so the best way to integrate it is through Cocoapods. The recommended version for Cocoapods is 1.9.3 or newer. If you already have a pod file, you just need to add the following line in your watch extension target:

```ruby
    pod 'AdswizzWatchSDK', :git => "https://github.com/adswizz/ad-sdk-ios.git"
```
 
After modifying the podfile, run `pod install`. You will be prompted to enter the security credentials to access the AdswizzSDK repository. You can obtain the credentials from your AdsWizz partner integration manager. Once authorization is successful, the framework will be installed.

## SDK integration
**_AdswizzWatchSDK_** doesn't need to be initialized.

### Watch Extension state
**_AdswizzWatchSDK_** needs to be informed of the state of your WatchOS extension. Here is how you can do that in ExtensionDelegate class:

```swift
import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    //Wrapper around WCSessionDelegate
    private lazy var sessionDelegate: SessionDelegate = {
        return SessionDelegate()
    }()

    override init() {
        super.init()
        // Activate the session asynchronously as early as possible.
        // In the case of being background launched with a task, this may save some background runtime budget.
        //
        WCSession.default.delegate = sessionDelegate
        WCSession.default.activate()
    }

    func applicationDidBecomeActive() {
        //notify AdswizzWatchSDK that extension is active
        AdswizzWatchSDK.shared.applicationDidBecomeActive()
    }

    func applicationWillResignActive() {
        //notify AdswizzWatchSDK that extension will be inactive
        AdswizzWatchSDK.shared.applicationWillResignActive()
    }

    func applicationWillEnterForeground() {
        //notify AdswizzWatchSDK that extension will enter foreground
        AdswizzWatchSDK.shared.applicationWillEnterForeground()
    }
    
    func applicationDidEnterBackground() {
        //notify AdswizzWatchSDK that extension entered background
        AdswizzWatchSDK.shared.applicationDidEnterBackground()
    }
}
```
Calling these **_AdswizzWatchSDK_** APIs is essential for **_AdswizzSDK_** to **_AdswizzWatchSDK_** communication.

Next, you need to link your **_WCSessionDelegate_** object to be notified by **_AdswizzWatchSDK_** or **_AdswizzSDK_** about watch messages you have to send to the other side.

```swift
#if os(iOS)
    let watchSession: WatchSession = AdswizzSDK.shared.watchSession.setDelegate(self)
#elseif os(watchOS)
    let watchSession: WatchSession = AdswizzWatchSDK.shared.watchSession.setDelegate(self)
#endif
```
This code is common to both platform iOS/WatchOS and can be treated in the same file that can be shared between your iOS app and your WatchOS extension.
Here is the setup of this common SessionDelegate class:

```swift
import Foundation
import WatchConnectivity
#if os(iOS)
import AdswizzSDK
#elseif os(watchOS)
import AdswizzWatchSDK
#endif

class SessionDelegate: NSObject {
#if os(iOS)
    let watchSession: WatchSession = AdswizzSDK.shared.watchSession
#elseif os(watchOS)
    let watchSession: WatchSession = AdswizzWatchSDK.shared.watchSession
#endif
    
    override init() {
        super.init()
        //set this object to handle WatchSessionDelegate
        watchSession.setDelegate(self)
    }
 }
```

### Forwarding messages from WCSession to AdswizzWatchSDK/AdswizzSDK
In SessionDelegate class we need to conform to WCSessionDelegate to handle two APIs that AdsWizz uses in order to send messages from iOS to WatchOS or vice-versa. Remember, this code is common to iOS (**_AdswizzSDK_**) and WatchOS (**_AdswizzWatchSDK_**).

```swift
extension SessionDelegate: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //inspect the data
        //If it is from AdsWizz SDK's, forward it to the WatchSession
        if message.isAdswizzWatchData {
            watchSession.receivedMessage(message)
        }
        //handle your data
        ....
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        //inspect the data
        //If it is from AdsWizz SDK's, forward it to the WatchSession
        if applicationContext.isAdswizzWatchData {
            watchSession.receivedMessage(applicationContext)
        }
        //handle your data
        ....
    }
}
```
**_AdswizzSDK_**/**_AdswizzWatchSDK_** provides an utility to inspect WatchOS-related messages and see if there is a need to forward them to the SDK.

### Sending messages from AdswizzWatchSDK/AdswizzSDK to WCSession
In SessionDelegate class we need to conform to **_WatchSessionDelegate_** to send messages over WCSession default object. When **_AdswizzSDK_**/**_AdswizzWatchSDK_** will call these functions all states regarding WCSession object will be verified internally in order to make the call.

```swift
extension SessionDelegate: WatchSessionDelegate {
    func sendMessage(_ data: [String : Any]) {
        //use sendMessage API to send a direct message to the other side.
        //The state of the WCSession was already verified internally in the SDK.
        WCSession.default.sendMessage(data, replyHandler: nil) { error in
            //log the error
        }
    }
    
    func updateApplicationContext(_ data: [String: Any]) {
        //use updateApplicationContext API to send the message.
        //The state of the WCSession has already been verified internally in the SDK.
        do {
            try WCSession.default.updateApplicationContext(data)
        } catch {
            //log the error
        }
    }
}
```

### Running your WatchOS companion app in the background
By default, most of the WatchOS companion apps will not run in the background, meaning the OS will not permit communication between iOS and WatchOS for your app. If, by  any chance, you have registered your app to play music in the background or you are running a work out session in your WatchOS extension you can notify **_AdswizzWatchSDK_** that you are running in the background. This will help you provide better targeting capabilities.

```swift
  AdswizzWatchSDK.shared.runningInBackground = true // your  WatchOS is running in the background
```
# Debugging AdswizzWatchSDK

The SDK uses an internal logger called **_AdLogger_**. By default, the logging level is set to none, meaning that nothing gets logged. Should you need the SDK logging events, you can enable a different logging level; verbose is the one with the highest density, hence we do not recommend its use in production.
You can also provide a new destination for the logger (e.g.: pipe it to your app logger). By default, the SDK dumps log events in the console.


```swift
extension ExtensionDelegate {
    func configureAdswizzSDK() {
      ......
      AdLogger.shared.level = .info
      AdLogger.shared.destination = self
      ......
    }
}
......
extension ExtensionDelegate: AdLoggerDestination {
  func log(_ level: AdLogger.Level, functionName: String, fileName: String, lineNumber: Int, line: String) {
      //Pipe it to your logger
  }
}
```

# Sample projects

Best way to see the **_AdswizzWatchSDK_** in action is by studying the example projects included in the `/Samples` folder. Download the `/Samples` folder using the below `git` command:
```properties
$ git clone https://github.com/adswizz/ad-sdk-ios.git
Username: adswizz-sdk
Password: your_access_token (provided by AdsWizz)
 ```

The examples are structured as separate projects in the _**Examples.workspace**_. Note that the samples workspace uses Cocoapods to install **_AdswizzWatchSDK_** and **_AdswizzSDK_** and necessary dependencies. To successfully build and run the samples you first need to run a `pod install` to make sure all the necessary dependencies are downloaded and resolved properly.
Next, open _**Examples.workspace**_ and run each sample individually by selecting the appropriate target and click 'Run' in XCode.

## BasicAdRequestWatchExample

This sample demonstrates how to use **_AdswizzWatchSDK_** in WatchOS companion app.
It shows how the main app project communicates through a watch extension using messages and updates a status label on the watch mirroring events happening in the iOS companion app.

### Getting started

For this purpose it uses a basic approach to show how to structure your app project with a WatchOS extension:
* **_BasicAdRequestWatchExample_** encapsulates the main app project
* **_BasicAdRequestWatch_** encapsulates the interface for the watch extension
* **_BasicAdRequestWatch Extension_** enacapsulates the logic for the watch extension

### Running the sample

To get the most out of the sample you would ideally run it with actual devices (both iOS and WatchOS). This way you will be able to interact with the watch when interactive ads are being played on the iOS companion app.
Also note the usage of [Now Playing](https://developer.apple.com/documentation/mediaplayer/becoming_a_now_playable_app) in **_BasicAdRequestWatchExample_**. When an interactive ad is being played it allows the iOS companion app to wake up the watch extension and take action on the watch itself (e.g shake the watch, use speech-to-text for voice ads, etc).

# Privacy implications

Please be advised that if you choose to enable the Raw Data Signal Collection, you will have to inform your customers that your application handles and processes personal anonymized data. <br>
**We highly encourage you to loop your product and legal teams in the process of defining the best way to reflect this in your application’s Privacy Policy.**

---------------------------------------------------------------------------------------------------------------------------------------------------
| Data collected for <br>**_Device Targeting_** | Data collected for <br>**_Contextual Targeting_** |
|:-----------------|:---------------------|
| * device type <br>* operating system version | * bluetooth devices (currently connected and history)|







