# Playing ads using your player

Out of the box, the AdswizzSDK is configured to play the ad media using its internal player. This behavior also extends to playing streams or podcasts.

## Client side setup

In a [Client-Side Insertion](/SDKiOS/ClientSideInsertion) scenario, if you prefer playing the ads with your own player, you must configure the **_AdManager_** object received after an **_AdConnectionRequest_** with a new **_AdManagerSettings_** object. Here you can provide the player, which must conform to the **_MediaPlayerState_** protocol. Through this protocol, the AdswizzSDK uses the KVO pattern to detect changes in your player. You can also check the [AdManager life cycle](/SDKiOS/ClientSideInsertion#admanager-life-cycle) diagram (right one) to see what is expected from your player, so that the **_AdManger_** can function properly.

Here is how you set up your own player:

```swift
class YourModelClass {
    var yourPlayer: YourPlayer

    func requestAds() {
        var zone: AdswizzAdZone!
        ......
        var adRequest: AdswizzAdRequest!
        do {
            adRequest = try AdswizzAdRequest.Builder()
                .with(server: "SERVER_PROVIDED_BY_PIM")
                .with(zone: zone)
                .build()
        } catch {
            print(error)
        }

        let adRequestConnection = AdRequestConnection(for: adRequest)
        adRequestConnection.requestAds { [weak self] adManager, error in
            self?.didReceiveResponse(adManager, error)
        }
    }

    func didReceiveResponse(_ adManager: AdManager?, _ error: Error?) {
        ......
        // Pass your player to the AdManager
        let adManagerSettings = AdManagerSettings()
        adManagerSettings.player = yourPlayer
        adManager?.adManagerSettings = adManagerSettings
        ......
 }

```

See the [MediaPlayerState example](/SDKiOS/ExternalPlayer#mediaplayerstate-example) for a more detailed implementation of the **_MediaPlayerState_** protocol.

## Server side setup

In a [Server-Side Insertion](/SDKiOS/ServerSideInsertion) scenario, if you prefer playing the ads with your own player, you must configure the **_AdManager_** object received when an ad break is detected in your stream with a new **_AdManagerSettings_** object. Here you can provide the player which must conform to the **_MediaPlayerState_** protocol.

Here is what it could look like in your code:

```swift
class YourModelClass {
    var streamManager: AdswizzAdStreamManager?

    func prepareForPlay() {
      ....
      do {
        streamManager = try AdswizzAdStreamManager.Builder()
        .with(adServer: "SERVER_PROVIDED_BY_INTEGRATION_MANAGER")           //Mandatory
        .with(httpProtocol: .https)                                         //Optional: http or https protocol for the ad server. Defaults to https.
        .with(companionZones: "COMPANION_PROVIDED_BY_INTEGRATION_MANAGER")  //Optional: companion zone provided by a Integration Manager
        .build()

        streamManager?.delegate = self //Receive notifications from AdswizzAdStreamManager

      } catch {
        print(error)
      }
    }
    ...

    func play(with url: URL) {
      streamManager?.play(with: url)
    }
    ...
}

extension YourModelClass: AdStreamManagerDelegate
    ......

    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakStarted manager: AdManager) {
      ......
      // Pass your player to the AdManager
      let adManagerSettings = AdManagerSettings()
      adManagerSettings.player = yourPlayer
      adManager.adManagerSettings = adManagerSettings
      ......
 }
......

```

See the [MediaPlayerState example](/SDKiOS/ExternalPlayer#mediaplayerstate-example) for a more detailed implementation for **_MediaPlayerState_** protocol.

## Podcasts setup

In a [Podcasts](/SDKiOS/Podcasts) scenario, if you prefer playing the ads with your own player, you can do so by playing the entire podcast with your player because the ads are "stitched" into the podcast media file.
Unlike playing live streams in a [Server-Side Insertion](/SDKiOS/ServerSideInsertion) scenario, after a podcast starts playing, even when your app receives an **_AdManager_** object containing the ads fetched from the Adswizz server, you cannot configure that **_AdManager_** object with a new **_AdManagerSettings_** object.

Here is what it could look like in your code:

```swift
class YourModelClass {
    var podcastManager: AdswizzAdPodcastManager?

    func prepareForPlay() {
      ....
      do {
        podcastManager = try AdswizzAdPodcastManager.Builder()
        .with(adServer: "SERVER_PROVIDED_BY_INTEGRATION_MANAGER")           //Mandatory
        .with(httpProtocol: .https)                                         //Optional: http or https protocol for the ad server. Defaults to https.
        .with(companionZones: "COMPANION_PROVIDED_BY_INTEGRATION_MANAGER")  //Optional: companion zone provided by a Integration Manager
        .build()

        // Pass your player to the podcastManager
        let adPodcastManagerSettings = AdPodcastManagerSettings()
        adPodcastManagerSettings.player = yourPlayer
        podcastManager?.adPodcastManagerSettings = adPodcastManagerSettings

      } catch {
        print(error)
      }
    }
    ...

    func play(with url: URL) {
      //play the entire podcast with your player (including any ads `stiched` in the podcast media file)
      podcastManager?.play(with: url)
    }
    ...
}

```

See the [MediaPlayerState example](/SDKiOS/ExternalPlayer#mediaplayerstate-example) for a more detailed implementation for **_MediaPlayerState_** protocol.

## MediaPlayerState protocol

Let’s break down the **_MediaPlayerState_** protocol.

### currentDuration

Your player needs to report the total duration of the media to the AdswizzSDK, as soon as possible. The media duration is required to compute quartile events or progress events in the SDK. If it is **not possible** to report the media duration, then **set it to 0**. If the SDK reads 0 from currentDuration, it will rely on the VAST metadata to get the file duration. If the info is missing in the VAST metadata as well, the quartile/progress events will be triggered at the end of the media playback in the correct order but not when the events actually happened.


### currentPlayHead

For accurate reporting of the quartile/progress events, your player should update its current position throughout the entire ad duration. It is **highly recommended** that your player updates this value at an interval of **1 second**. Updating at a higher frequency (<1s) might incur performance issues. If your player skips forward or backward as the ad is playing, immediately update this member accordingly to reflect the action taken. This will affect the way quartile events are fired by the SDK.


### metadataItem

If your player can read metadata from the media that is playing, it should report it through this member. While this is not required for client-side insertion, it is mandatory to relay this data when you are in a server-side insertion scenario. It is also required if your player is used in a podcast context for reporting any ID3 metadata formats to enable [Remote Audio Data](/SDKiOS/Podcasts#remote-audio-data) measurement.


### playerStatus

While your player is playing the ad, it should update this member so that the AdswizzSDK can start monitoring the status of the ad through your player. **Failing to update** this member accordingly will render **_AdManager_** incapable of generating normal events.
You should put your player in the **_initialized_** state upon receiving the ad URL from the **_AdManager_**, on the **_preparingForPlay_** event in the following function:

```swift
func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent)
```

If your player cannot load the ad URL, the player should report the **_failure_** state. You also need to set this state in case the error occurs during the ad playback, and the ad cannot be played anymore. 
When you set **_failure_** or **_unknown_** as the state of your player, the SDK will terminate the current ad that was sent in **_preparingForPlay_**, and inform your app that the media player state is **_unknown_**. The AdManager will move to the next ad, if available.

If your player is buffering data, you can report this to the SDK by setting the state to **_buffering_**. Once your player finishes buffering, you need to report **_bufferingFinished_**. Reporting **_buffering_** and **_bufferingFinished_** ensures that quartile/progress events are reported correctly and are not subject to network interruptions. Once your player is ready to play the ads (after buffering enough data), it can report a state of **_readyToPlay_**, meaning the player’s play method may be called. This state is optional and it resembles the AVPlayer currentItem readyToPlay status. If your player has started the ad playback, set the state to **_playing_**. If you pause the playback, set the state to **_pause_**. Similarly, **Resume** will change the state to **_playing_** again. When the player has finished playing the ad, set the state to **_finished_**.

Here is a state machine for your player to implement.
<img src="/img/MediaPlayerState.png" width="1000" />

### isBufferingWhilePaused

If your player continues to buffer data after it was paused, set this property to true. When you are playing a stream, this is a good way to let the SDK decide whether or not it should pick up from where it was paused or reconnect to the live stream again. 

### lastError

If your player encountered an error while playing an ad, report it in this property. This will help the SDK to better report errors back to the ad server.

### capabilities

If your player has specific capabilities (skip, mute, autoplay, autoplay when muted, fullscreen or it can display an icon), list them in this property. The SDK will relay this information to the ad server, which will ultimately help achieve better targetability. If you are not interested in this feature, then set this property to nil.

### stateInfo

This is a collection of IAB-specific states (skipped, muted, autoplayed, fullscreen) that your player may go through. Reporting these accordingly will help the SDK relay this information to the ad server, and will ultimately help achieve for better targetability. If you are not interested in this feature, then set this property to nil.

### volume

If your player can update the volume of the media, update this property with a value between 0.0 and 1.0. A value of 0.0 indicates silence; a value of 1.0 (the default) indicates full audio volume for the player instance.

## MediaPlayerState example

Assuming your player is a direct subclass or a wrapper for **_AVPlayer_**, here is an example of how to implement the **_MediaPlayerState_** protocol. It also highlights how your player should behave.

```swift

class YourPlayer: NSObject, MediaPlayerState {

    private var player: AVPlayer?
    private var timeObserverToken: Any?

    ......

    func setupPlayer() {
        ...
        player = AVPlayer()
        ...

        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { [weak self] time in
            self?.updatePlayhead(time)
        })
    }

    private func updatePlayhead(_ newTime: CMTime?) {
        guard
            let newTime = newTime,
            let currentItem = player?.currentItem
        else {
            return
        }
        
        let itemDuration = CMTimeGetSeconds(currentItem.duration)
        internalPlayHeadPosition = min(CMTimeGetSeconds(newTime), itemDuration.isNaN ? Double.greatestFiniteMagnitude : itemDuration)
    } 

    ......

    /// IMPORTANT: this 'internalPlayHeadPosition' is needed otherwise KVO won't work. See ExternalPlayerExample from Samples.
    /// using this 'internalPlayHeadPosition' variable to forward updates to 'currentPlayhead' for AdswizzSDK. Use the same approach in your code.
    @objc private dynamic var internalPlayHeadPosition: TimeInterval = 0 {
        willSet {
            print("Setting playHead to \(newValue)")
        }
    }


    /// currentPlayhead is observable from AdswizzSDK, so any time you update it, the SDK will react to it's change
    /// Important notes:
    ///  1. The SDK might decide to query the value at random time, so your code must be prepared to reflect the exact time of the playhead . For example: AdswizzSDK recommands 'currentPlayhead' be updated every 1 sec but it might decide to query the value between updates. If the SDK queries this values while your player is 1.3 seconds into playing the value returned should be 1.3 seconds, not 1 second. To achieve this behaivour 'currentPlayhead' is not updated directly, but an intenal value called 'internalPlayHeadPosition' is used. Use the same approach in your code.
    ///  2. The SDK expects 'currentPlayhead' to be ascending order. Internally, the SDK will compute your reported playhead with the passed time since the last update it received from your player to decide if a continouos playing sequence is in progress. This means, that the SDK will detect if your player has done a seek or not. Continous playing will affect quartile reporting of the ad as per IAB documentation recommands.
    /// Expected values: any value in [0..duration] interval, values must be in ascending order.
    /// Importance for the SDK: HIGH
    @objc dynamic public var currentPlayhead: TimeInterval {
        get {
            return min(internalPlayHeadPosition, currentDuration)
        }
    }

    /// playerStatus is very important. Your player should start with 'initialized' every time is begins playing. This is mandatory.
    /// Expected values: any MediaPlayerStatus value. See the Integration Guide for a complete state machine for your player.
    /// Importance for the SDK: HIGH
    @objc dynamic public var playerStatus: MediaPlayerStatus = .initialized {
        willSet {
            print("Setting status to \(newValue.stringValue)")
        }
    }

    /// Whenever you have metadata, update this value. This is usefull when you use your player to play a stream. Failing to update the 'metadataItem' will result in AdswizzSDK not being able to use interactive ads while playing an Adswizz stream.
    /// Expected values: any values of type [AVMetadataItem]
    /// Importance for the SDK: HIGH
    @objc dynamic public var metadataItem: [AVMetadataItem]?


    /// This value represents the duration in seconds of the media your player is currently playing. If you don't have it yet return 0.
    /// Expected values: [0..maxDurationOfTheMedia]
    /// Importance for the SDK: MEDIUM
    @objc dynamic public var currentDuration: TimeInterval {
        guard let duration = player?.currentItem?.duration else {
            return 0
        }
        let seconds = CMTimeGetSeconds(duration)
        return seconds.isNaN ? Double.greatestFiniteMagnitude : seconds
    }


    /// Update volume if your player has the ability to change the volume of the content.
    /// Expected values: any values in interval [0..1] where 1 means 100% of the original value. If your player does not support volume changes return 1.
    /// Importance for the SDK: LOW
    @objc dynamic public var volume: Float = 1


    /// This is optional. This should be a global setting for your player which informs the SDK that it will continue to buffer data for some time after it was paused. This is usefull for the SDK while playing  a stream.
    /// Expected values: true if the player will continue buffering data after pausing, or false if the player suspends buffering while pausing.
    /// Importance for the SDK: LOW
    @objc public var isBufferingWhilePaused: Bool = false

    /// Update this member with the last error that happend in your player. This will help the SDK to better report the erros back the AD servers.
    /// Expected values: any Error
    /// Importance for the SDK: LOW
    @objc public var lastError: Error?

    /// This should be a global setting for your player which informs the SDK what capabilities does your player support. This will be used by the SDK for better targeting. If you do not support any capability set this to nil
    /// Expected values: nil or a set of IAB capabilities
    /// Importance for the SDK: LOW
    @objc public var capabilities: Set<MediaPlayerCapability>?

    /// Whenever your player is using a MediaPlayerCapability described above, update the state of your player. Each MediaPlayerCapability can return a state.
    /// Expected values: nil or a set of IAB state capabilities obtained from an MediaPlayerCapability object
    /// Importance for the SDK: LOW
    @objc public var stateInfo: Set<MediaPlayerCapability.State>?
}

//IMPORTANT
extension YourPlayer {

    // override keyPathsForValuesAffectingValue and return 'internalPlayHeadPosition' as the affected keyPath for 'currentPlayhead'
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        //trigged currentPlayhead when internalPlayHeadPosition changes
        if key == "currentPlayhead" {
            return ["internalPlayHeadPosition"]
        }
        else {
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
}

```
Notice how your player class that implements **_MediaPlayerState_** protocol should inherit from **_NSObject_** which is needed for the KVO mechanism in Swift.

For a complete implementation, we strongly suggest to consult [ExternalPlayerExample](/SDKiOS/ExternalPlayer) from [Sample projects](/SDKiOS/SampleProjects) and the `ExternalMediaPlayer.swift` source file.