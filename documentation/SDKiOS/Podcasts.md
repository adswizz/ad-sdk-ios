# Podcasts

Podcast apps that integrate the AdswizzSDK will benefit from real-time reporting, companion display and interactive ads with formats such as ShakeMe and VoiceAds. Of course, these features are available only if the podcasts are delivered by AdsWizz's AIS. The setup uses an underlying functionality similar to Server-Side Insertion, as well as some familiar Client-Side Insertion objects such as **_AdManager_**.

## Build AdswizzAdPodcastManager

To get started, you need to create an **_AdswizzAdPodcastManager_** object.

```swift
import AdswizzSDK

class YourModelClass: AdPodcastManagerDelegate, AdPodcastManagerDownloadDelegate {
   var podcastManager: AdswizzAdPodcastManager?

func prepareForPlay() {
....
do {
    podcastManager = try AdswizzAdPodcastManager.Builder()
        .with(adServer: "SERVER_PROVIDED_BY_INTEGRATION_MANAGER") //Mandatory
        .with(httpProtocol: .https)                               //Optional: http or https protocol for the ad server. If not provided https will be chosen.
        .with(companionZones: "COMPANION_PROVIDED_BY_INTEGRATION_MANAGER")  //Optional: companion zone provided by a Integration Manager
        .build()
} catch {
    print(error)
}
...
}

```

The **_AdswizzAdPodcastManager_** object can be configured with a companion zone that will be used in case the ad breaks do not define a companion zone in the AIS Zero Config of the podcast.

This is your only entry point to drive the podcast functionality further; typically your app will need a single **_AdswizzAdPodcastManager_** instance. Note that you should keep a strong reference to this object.

Next, in order to receive callbacks from the podcast manager you need to set the delegate defined in [AdPodcastManagerDelegate](#adpodcastmanagerdelegate-protocol) protocol:

```swift
podcastManager?.delegate = self
```

## Setup AdswizzAdPodcastManager

Once the podcast manager object is constructed, you can further customize your **_AdswizzAdPodcastManager_** object by using the **_AdPodcastManagerSettings_** class. Here is a breakdown for the available settings.

### player

The `player` property instructs the **_AdswizzAdPodcastManager_** object to play the podcast with your player or use an internal player.
If you decide to play the podcast with your player, you need to provide a **_MediaPlayerState_** object with the following code:

```swift
let settings = AdPodcastManagerSettings()
settings.player = yourPlayer
podcastManager?.adPodcastManagerSettings = settings
```

See the [MediaPlayerState example](/iOS/SDKiOS/ExternalPlayer#mediaplayerstate-example) for a more detailed implementation of the **_MediaPlayerState_** protocol.

### automaticallySecureConnectionForAdURL

Enables secure connections when **_AdswizzAdPodcastManager_** object fires additional internal requests. The default value is `true`.
Here is an example on how to instruct the **_AdswizzAdPodcastManager_** object to secure or not its internal requests:

```swift
let settings = AdPodcastManagerSettings()
settings.automaticallySecureConnectionForAdURL = false // Optional; true by default
podcastManager?.adPodcastManagerSettings = settings
```

> The **_AdswizzAdPodcastManager_** object will always attempt to use a secured connection (HTTPS protocol) when firing internal requests for fetching additional ad breaks related information from the podcast metadata.
> This approach avoids the need for whitelisting these requests in your application.

## Playback operations

### play

Calling this method from **_AdswizzAdPodcastManager_** with an URL will begin playing either remotely or locally from a location on disk. This method should be called  even if the podcast is played with an external player, because the remote URL will be enhanced by the SDK with extra parameters that enable the delivery of ads from an Adswizz server.

Additionally, `play(with: URL)` will perform two important operations if needed:

* attempt to load and prepare for RAD metadata
* attempt to generate and build an **_AdManager_** for handling ads

As a response, if an error was encountered when performing the above operations, `AdswizzSDK` will call back func `adPodcastManager(_ adPodcastManager: AdPodcastManager, didFailPlaying url: URL, error: Error)`. The error will be related to the connection with the AIS server that hosts the podcast.
However if **_AdswizzAdPodcastManager_** hasn't encountered any issue, it will call back func `adPodcastManager(_ adPodcastManager: AdPodcastManager, willStartPlaying url: URL)` with the newly formatted URL. At this point, **_AdswizzAdPodcastManager_** signals that buffering/playback is about to start.

Note that, when you start playing a podcast from either a local or remote URL, specific events from the buffering state will be available through **_AdPodcastManagerDelegate_** via the `func adPodcastManager(_ adPodcastManager: AdPodcastManager, stateChanged state: MediaPlayerStatus)` method. Expected events here will be `buffering`, `bufferingFinished` and `readyToPlay`.

### pause

Calling this method will pause a podcast that is played by the SDK’s internal player. If an external player is used, this will have no effect. If an internal player is used, the podcast will continue to buffer internally for some 60 seconds.

### resume

Calling this method will resume a podcast that is played by the SDK’s internal player. For an external player, this will have no effect.

### stop

Calling this method will stop a podcast that is played by the SDK’s internal player. For an external player, this will have no effect.

### seek

Callng `seek(to time: TimeInterval, completion: () -> Void) throws` will trigger a seek by setting the current playback time to the specified `time` parameter measured in seconds. Note that the completion handler is only called if the operation did not throw any error. For an external player this method will have no effect. However, if you are using your own player, the SDK will automatically detect it and adjust the tracking for various events during playback, such as quartile reporting.

## Download operations

**_AdswizzAdPodcastManager_** also exposes download functionality to be able to store and play podcasts from the `Library` local folder on the device.
As best practice, downloading a podcast should continue even when your app is put in the background. As per [Apple's Documentation](https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background/), to enable this behavior in your app, all you need to do is to implement the following app delegate method:

```swift

func application(_ application: UIApplication,
                 handleEventsForBackgroundURLSession identifier: String,
                 completionHandler: @escaping () -> Void) {
        AdswizzSDK.shared.backgroundSessionCompletionHandler = completionHandler
}


```
Notice that `completionHandler` is passed to **_AdswizzSDK_** shared instance into a property called `backgroundSessionCompletionHandler`. You can find more information here: [Enable background downloads](/iOS/SDKiOS/GeneralSettings#enable-background-downloads).

### start download

To begin downloading a podcast, the `startDownloadPodcast(with url: URL, to location: URL)` method takes a remote URL to download from and a location file URL as destination to save the media file once the download is complete. Similar to the `play(with url: URL)` method, the remote URL will be enhanced by **_AdswizzAdPodcastManager_** with extra parameters that enable the delivery of ads from an Adswizz server when the podcast is played.

### stop download

Calling the `stopDownloadPodcast(at location: URL)` method cancels a previously started download operation for a podcast at its location file URL as destination on disk.

### remove

Calling `removePodcast(at location: URL)` method removes a previously downloaded podcast at its location file URL as destination on disk.

## AdPodcastManagerDelegate protocol

Playback and ad break-related notifications sent from **_AdswizzAdPodcastManager_** to your app are implemented in the **_AdPodcastManagerDelegate_** interface.

### func adPodcastManager(_ adPodcastManager: AdPodcastManager, willStartPlaying url: URL)

After calling the play function in the **_AdswizzAdPodcastManager_** object, this delegate method will be called with the (remote) URL decorated with the extra parameters. Here, an external player can be instructed to start playing the podcast. If the SDK uses the internal player, no additional action is required at this point.

```swift
func adPodcastManager(_ adPodcastManager: AdPodcastManager, willStartPlaying url: URL) {
  yourPlayer.play(url)
}
```

### func adPodcastManager(_ adPodcastManager: AdPodcastManager, didFailPlaying url: URL, error: Error)

When the play function is called in the **_AdswizzAdPodcastManager_** object, this delegate will be called back if the podcast manager was unable to communicate with the AIS server and failed to prepare and fetch the required `AdManager`. When this delegate method is called, the podcast will not start any buffering/playback.
To attempt to play the podcast with `url` again, your app needs to call the `play` function in the **_AdswizzAdPodcastManager_** object.

### func adPodcastManager(_ adPodcastManager: AdPodcastManager, stateChanged state: MediaPlayerStatus)

When the state of either the SDK's internal player or the external player changes, your app will get notified in this function. The states here can be used to update the UI accordingly.

### func adPodcastManager(_ adPodcastManager: AdPodcastManager, playheadChanged playhead: TimeInterval, duration: TimeInterval)

Every time the current playhead of either the SDK internal player or the external player changes, your app will get notified in this function. The duration reflects the total expected podcast duration. This method can also be used to update the UI accordingly.

### func adPodcastManager(_ adPodcastManager: AdPodcastManager, didReceive manager: AdManager)

After a podcast starts playing, your app can receive an **_AdManager_** object containing the ads fetched from the Adswizz server. This **_AdManager_** can be used the same way after getting it from an **_AdswizzAdRequest_**, except there is no need to keep a strong reference to the object. Here is how it might look in your app's integration:

```swift
func adPodcastManager(_ adPodcastManager: AdPodcastManager, didReceive manager: AdManager) {
    //let settings = AdManagerSettings()
    //settings.player = yourAdPlayer     // this step has no effect on this kind of AdManager because the ads are played with current podcast player
    //manager.adManagerSettings = settings
    manager?.delegate = self             // register for notifications on this AdManager
    manager?.interactiveDelegate = self  // register for interactive ads notifications
}
```
During podcast playing, the **_AdswizzAdPodcastManager_** listens to the current `playhead` property of the player and detects ad breaks in the podcast based on the associated playhead start positions of the ads stitched within the podcast.

During an ad break, your app will receive updates on the status of the ad if the **_AdManagerDelegate_** or the **_InteractiveAdManagerDelegate_** protocol is implemented. When this **_AdManager_** object is received, the **_AdswizzAdPodcastManager_** handles the ad breaks internally. As a result, during ad playback, **_AdManager_** will not react to operations such as `play()` or `pause()` since the ad break is part of the podcast. However, the ad break can be `skipped` or the whole **_AdManager_** object can be `reset`. When the listener interacts with an ad (i.e. ShakeMe), in order to play an extension of the ad, it is expected that other ads will be inserted in the **_AdManager_** container if the main ad is extended.

### func adPodcastManagerPlayerShouldPause(_ adPodcastManager: AdPodcastManager) 

When playing with an external player, the SDK informs your app to pause the content from playing.

### func adPodcastManagerPlayerShouldResume(_ adPodcastManager: AdPodcastManager)

When playing with an external player, the SDK informs your app to resume playing the content after being previously paused.

### func adPodcastManagerPlayer(_ adPodcastManager: AdPodcastManager, shouldSeekTo time: TimeInterval, completion: @escaping () -> Void)

When playing with an external player, the SDK informs your app to seek forward the content when an ad is skipped. When this gets called you should seek to the `time` relative to the podcast duration as suggested by the **_AdswizzAdPodcastManager_**.
Note that when your player completes the seek operation, it is important that your app call the specified completion block back to the SDK. Here is an example where `player` is an external player (that implements `MediaPlayerState` interface) based on Apple's `AVPlayer`:

```swift
func adPodcastManagerPlayer(_ adPodcastManager: AdPodcastManager, shouldSeekTo time: TimeInterval, completion: @escaping () -> Void) {
    player?.seek(to: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                 toleranceBefore: CMTime.zero,
                 toleranceAfter: CMTime.zero) { _ in
        //when player has completed the seek operation, call the completion back to the SDK
        completion()
    }
}
```

## AdPodcastManagerDownloadDelegate protocol

Download-related notifications sent from **_AdswizzAdPodcastManager_** to your app are implemented in the **_AdPodcastManagerDownloadDelegate_** interface.

### func adPodcastManager(_ adPodcastManager: AdPodcastManager, didDownload bytesDownloaded: Int64, outOf bytesExpected: Int64, for asset: DownloadableAsset)

This method gets called when a podcast has already started downloading and a chunk of data was received. It sends all the necessary data to compute the progress needed for any UI updates. It also encapsulates the asset being downloaded into a **_DownloadableAsset_** that is kept alive until the download finishes.

The **_DownloadableAsset_** object provides info on the asset being handled:
* url - the remote URL that the asset is downloading from
* mimeType - the creative type e.g "audio/mp3"
* expectedContentLength - should match bytesExpected in the progress callback
* state - the current state e.g `downloading`, `ready`, `failed`
* location - the local file URL path where the asset will be saved once download completes

### func adPodcastManager(_ adPodcastManager: AdPodcastManager, didFinishDownload asset: DownloadableAsset)

Called when the asset finished downloading all of its data.

### func adPodcastManager(_ adPodcastManager: AdPodcastManager, didReceive error: Error, for asset: DownloadableAsset)

Called when a network error occurred while trying to download the asset.

## AdswizzAdPodcastManager state diagram

<img src="/img/AdswizzAdPodcastManagerState.png" width="1000" />

## Handling interactive ads during podcasts

For more information on how to handle interactive ads such as ShakeMe and Voice Ads please refer to the [Interactive ads](/iOS/SDKiOS/InteractiveAds#interactive-ads) section.
Note that the interactivity component of an ad requires fetching data from a remote service that may not be available for downloaded podcasts especially when there is no internet connection.

## Remote Audio Data

Podcasts come with _Remote Audio Data_ (RAD) support. Based on the industry standard by [NPR](https://rad.npr.org/), each podcast with RAD metadata will send events everytime its playhead crosses a certain point in time. 
To enable RAD measurement for your podcasts, additional ZeroConfig configuration is needed. Contact your AdsWizz partner integration manager to setup your app's AdswizzSDK ZeroConfig instance.
After this is in-place, as best practice you should present your users with the option to opt in or out for RAD measurement when playing podcasts. 

This can be achieved with a single line of code:

```swift
AdswizzSDK.shared.disableRAD = false //or `true` if user opted out
```       
By default, when `AdswizzSDK` is initialized, the `disableRAD` property is set to `false`, so RAD measurement is **enabled** by default.
 
The `disableRAD` property is applied to all podcasts and can be updated on the fly. When RAD measurement is disabled, all current event uploads are cancelled and the local database is emptied.

Disabling RAD data collection at the ZeroConfig level takes precedence over disabling it from code. If RAD is disabled in ZeroConfig, setting a new value to the `disableRAD` property will be the same as setting this value to `false` everytime.

### Handling RAD id3 metadata using your player

Remote Audio Data measurement is based on reading specific `id3` metadata formats from the podcast being played. The SDK is able to read these specific metadata formats when playing with the internal player.
However, when playing podcasts using your own player, you are responsable for passing the metadata items to the SDK. You can find more details in the [MediaPlayerState protocol](/iOS/SDKiOS/ExternalPlayer#mediaplayerstate-protocol) and [metadataItem](/iOS/SDKiOS/ExternalPlayer#metadataitem) sections.

