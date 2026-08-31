# Server-Side Insertion

The AdswizzSDK handles interactive ad insertions, while playing HLS or ICY live streams from Ad Insertion Servers. This is possible by reading the player's metadata for specific AdsWizz data and converting it to AdsWizz interactive formats or companion banners.
To get started, you need to create an **_AdswizzAdStreamManager_** object with a URL pointing to the ad server your Integration Manager provided you with.
> Since **_AdswizzSDK_** `v8.0.0` the objects used below are `@MainActor` isolated, which is why the sample types are annotated `@MainActor` and their **_AdswizzSDK_** delegate conformances are isolated. See the [v8.0.0 migration guide](iOS/SDKMigrations/v8_0_0.md) for details.


## Build AdswizzAdStreamManager

```swift
import AdswizzSDK

@MainActor
class YourModelClass: @MainActor AdStreamManagerDelegate {
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

Next, in order to receive callbacks from the stream manager you need to set the delegate defined in [AdStreamManagerDelegate](#adstreammanagerdelegate-protocol) protocol:

```swift
streamManager?.delegate = self // Where `self` is an object that conforms to `AdStreamManagerDelegate`
```

## Setup AdswizzAdStreamManager

You can further customize your **_AdswizzAdStreamManager_** object by using the **_AdStreamManagerSettings_** class. Here is a breakdown for the available settings.

### player

The `player` property instructs the **_AdswizzAdStreamManager_** object to play the stream with your player or use an internal player.
If you decide to play the stream with your player, you need to provide a **_MediaPlayerState_** object with the following code:

```swift
let settings = AdStreamManagerSettings()
settings.player = yourPlayer
streamManager?.adStreamManagerSettings = settings
```

See the [MediaPlayerState example](/iOS/SDKiOS/ExternalPlayer#mediaplayerstate-example) for a more detailed implementation of the **_MediaPlayerState_** protocol.

### capabilities

This property bundles various capabilities that the **_AdswizzAdStreamManager_** object should use or enable.

#### dvr

Enables the DVR capability for HLS streams.

```swift
let settings = AdStreamManagerSettings()
settings.addCapability(.dvr) // Enables DVR
streamManager?.adStreamManagerSettings = settings
```

See the [DVR for HLS](#dvr-for-hls) section below for more details.

### automaticallySecureConnectionForAdURL

Enables secure connections when **_AdswizzAdStreamManager_** object fires additional internal requests. The default value is `true`.
Here is an example on how to instruct the **_AdswizzAdStreamManager_** object to secure or not its internal requests:

```swift
let settings = AdStreamManagerSettings()
settings.automaticallySecureConnectionForAdURL = false // Optional; true by default
streamManager?.adStreamManagerSettings = settings
```

> The **_AdswizzAdStreamManager_** object will always attempt to use a secured connection (HTTPS protocol) when firing internal requests for fetching additional ad breaks related information from the stream metadata.
> This approach avoids the need for whitelisting these requests in your application.

## Precaching before playing

This applies only when deciding to play a stream using the internal player. If you require a smooth transition between a user action to play a stream and the actual stream playing, you can call `prepare(with url: URL) throws` on your stream manager object ahead of `play(with url: URL) throws` and **_AdswizzSDK_** will make sure to buffer at most 10 seconds from your stream. You can call this function multiple times to refresh the buffer. This function is optional. Events from calling `prepare` will be received in `func adStreamManager(_ adstreamManager: AdStreamManager, stateChanged state: MediaPlayerStatus)`.

## AdswizzAdStreamManager operations

### prepare

When playing the stream with the internal player, call this to have a buffer ready when you call play. This is optional. Calling this while the stream is playing or paused will have no effect. If you call this function's events from the buffering stage, it will be available through **_AdStreamManagerDelegate_** within the stateChanged function. Usually, the events received here will be **_buffering_**, **_bufferingFinished_** and **_readyToPlay_**. You won't be notified when all 10 seconds have been buffered but you can rely on the **_readyToPlay_** state as a signal that **_AdswizzAdStreamManager_** can begin to play smoothly.

### play

To start playing a stream, call this function from **_AdswizzAdStreamManager_** with an URL to a valid AIS server. 
You should call this function even if you are playing the stream with your own player, because the URL will be enhanced with extra parameters that enable the delivery of interactive ads and companion banners. As a response, the **_AdswizzSDK_** will call back `func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL)` with the newly formatted URL.

### pause

To pause a stream that is played by the SDK internal player, call this function. If you are using your own player this will have no effect. If you are using the internal player, the stream will continue to buffer internally for some 60 seconds.

### resume

To resume a stream that is played by the SDK internal player, call this function. If you are using your own player this will have no effect.


### stop

To stop a stream that is played by the SDK internal player, call this function. If you are using your own player this will have no effect.


## AdStreamManagerDelegate protocol
Notifications sent from the **_AdswizzSDK_** to your app are implemented in the **_AdStreamManagerDelegate_** protocol. 

### func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL)
After calling the play function in the **_AdswizzAdStreamManager_** object, you will be called on this function with the URL decorated with the extra parameters. 
Here you can instruct your player to start playing the stream, in case you have chosen to use your own player. 
If you've decided to use the SDK internal player, you don't need to do anything at this point.

```swift
func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL) {
  yourPlayer.play(url)
}
```

### func adStreamManager(_ adstreamManager: AdStreamManager, stateChanged state: MediaPlayerStatus)
Whenever the state of the SDK internal player or the state of your own player changes, you will get notified in this function. Use the states here to update your UI accordingly.

### func adStreamManager(_ adstreamManager: AdStreamManager, metadataChanged metadata: [AVMetadataItem])
Whenever the metadata is changed on the stream played by the SDK internal player, you will be notified here. 
If you opted to play the stream with your own player, this function won't be called.

### func adStreamManager(_ adstreamManager: AdStreamManager, adBreakStarted manager: AdManager)
When an ad break is detected in your stream, you will get a **_AdManager_** object containing the current running ad. You can handle this object the same way you did after getting it from an **_AdswizzAdRequest_**, except that you are not obligated to keep a reference to the object. 
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
When you get this **_AdManager_** object, the SDK internal player will automatically play the ad, since it is part of the stream. During the ad time, **_AdManager_** will not react to operations such as play or pause. However, you can skip the ad break or reset the whole **_AdManager_** object. Most of the times there will be only one ad in the **_AdManager_** object but you can expect other ads to be inserted from the SDK if the ad is extended. This can happen, for instance, when the listener interacts with an ad (i.e. ShakeMe), in order to listen to an extension of the ad (which provides more details on the topic).

### func adStreamManager(_ adstreamManager: AdStreamManager, adBreakEnded manager: AdManager)
When the ad break from the stream has ended you will get notified to clean up anything related to your **_AdManager_**.

```swift
func adStreamManager(_ adstreamManager: AdStreamManager, adBreakEnded manager: AdManager) {
    manager?.delegate = nil
    manager?.interactiveDelegate = nil
}
```

### func adStreamManagerWillReconnect(_ adstreamManager: AdStreamManager)
While interacting with an ad in the ad break, the stream might interrupt due to actions like skip ad or extend ad. At this time, the SDK will inform you that it will reconnect to the stream so the current ad will not be served again.

### func adStreamManagerPlayerShouldPause(_ adstreamManager: AdStreamManager)
When deciding to play with an external player the SDK informs you to pause the ad playing.

### func adStreamManagerPlayerShouldResume(_ adstreamManager: AdStreamManager)
When deciding to play with an external player the SDK might inform you to resume the ad playing.

Here is a diagram of the AdswizzAdStreamManager state.

<img src="/img/AdswizzAdStreamManagerState.png" width="1000" />

## DVR for HLS

DVR for HLS is a functionality that allows streams configured for DVR to play from a previous position in time. This is achieved internally by storing a buffer with a specified length (2 hours, 10 hours etc.) which a server uses to deliver audio content from a specified Unix time.

Code-wise, you have to attach a timestamp parameter to the `play` method and setup the current adstream object by adding the `dvr` capability. Just before the first play:

[Step 1]
```swift
let settings = AdStreamManagerSettings()
settings.addCapability(.dvr)
streamManager?.adStreamManagerSettings = settings
```

Afterwards the stream must start playing as usual without specifying a timestamp. After the first chunk is delivered, an `AdStreamSession` is created internally which will be used transparently by the SDK to perform DVR operations. At this point in time the SDK will also deliver a `AdStreamDVRMetadata` object via the `AdStreamDelegate` with information about the DVR buffer: a start time symbolizing the first Unix time in the buffer that can be played, an end time or latest which is very close to the current present time, and a length for the buffer, symbolizing how much audio the server will store (1h, 6 h etc). Please note the buffer is configured externally, server-wise and can be stored on a different server than the one that serves the HLS stream.

[Step 2]
```swift
try streamManager?.play(with: url)
```

Delegate method to receive metadata. Please note that this implementation is optional.
```swift
func adStreamManager(_ adstreamManager: AdStreamManager, didReceive dvrMetadata: AdStreamDVRMetadata?) { 
}
```

[Step 3]
After playing the stream as usual, the server is now ready to deliver sound from the past. Just pass in an `NSNumber` with a Unix timestamp in milliseconds and you're good to go:


```swift
try streamManager?.play(with: url, timestamp: NSNumber(value: timestamp))
```

After this call the user can issue another play with a different timestamp. 

Currently DVR-enabled streams do not support `prepare()` calls. Calling `prepare` on a DVR stream and afterwards play will result in an error. The DVR session has a limited lifespan(45 s or anything that is configured). Stopping a DVR enabled stream and afterwards calling play with a timestamp after this interval will play the stream from the latest time. 

To get a new DVR session please start from [Step 2]. 

Complete code example:

```swift
let settings = AdStreamManagerSettings()
settings.addCapability(.dvr)
streamManager?.adStreamManagerSettings = settings

[...]

try streamManager?.play(with: url)

[...]
// After play is called and some time has passed (the first chunk has been downloaded)
// perform DVR 
try streamManager?.play(with: url, timestamp: NSNumber(value: timestamp))
```

## Augment the streamURL using decorate url static method

Starting with SDK version 7.12.3 a new static method named `decorate(_ url: URL) throws -> URL` was added to the `AdswizzAdStreamManager` class, in case you need to use it in a synchronous context to augment your stream `url` with AdsWizz specific query items.

Example of usage:

```swift
        guard let url = URL("http://sdk.mobile.streaming.adswizz.com:8500/shakeDemo") else { return }
        do {
            let decoratedURL = try AdswizzAdStreamManager.decorate(url)
            print("AdswizzAdStreamManager.decorateUrl: ", url, decoratedURL)
        } catch {
            print("Failed to decorate url: \(error)")
        }
```

```
http://sdk.mobile.streaming.adswizz.com:8500/shakeDemo

will be transformed in

http:/sdk.mobile.streaming.adswizz.com:8500/shakeDemo?aw_0_1st.sessionid=1748273017863.617.361522&aw_0_1st.cb=1748273092831.468018.22209&aw_0_1st.version=7.12.3%3Aios18.2&aw_0_awz.appVers=1.0%3A1&aw_0_req.lmt=1&aw_0_1st.ts=1748273092&aw_0_req.bundleId=com.adswizz.Artemis&aw_0_1st.playerId=artemisSwiftIos&aw_0_req.permissions=NNNNNNNNN11NN&calendar=N&sdkiad=1&call=1&pkpass=1&companionAds=true&aw_0_req.wopp=0&aw_0_req.appState=fg&aw_0_awz.listenerid=00000000-0000-0000-0000-000000000000
```
