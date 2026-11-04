# HLS Interstitials

Since iOS 15 at WWDC 2021, Apple introduced built-in support for **HLS interstitials** in the native **AVPlayer**. This functionality provides native support to handle displaying ads using a single player in an unified manner for both streaming and client side insertion.

Here are some of the benefits of using HLS Interstitials:
* Ads are separate assets scheduled onto a primary program timeline
* Dynamic - late binding and re-binding to ad inventory
* Arbitrary placement of interstitials
* Offers built-in navigation restrictions
* Supports AirPlay and Picture-In-Picture
* Optimal use of network and system resources

HLS Interstitials provide better performance, improved user experience and cleaner code in the end.<br>
Augmented with the **_AdswizzSDK_**’s various analytics capabilities and innovative ad formats (i.e Companion Banner, ShakeMe ads) it becomes a powerful tool for any content monetisation platform.

In the following sections we explore how to fully integrate **_AdswizzSDK_** with native HLS interstitials support in your own application.

> To learn more about HLS interstitials standard, visit Apple's documentation:
> * [Getting Started with HLS Interstitials](https://developer.apple.com/streaming/GettingStartedWithHLSInterstitials.pdf)
> * [Explore dynamic pre-rolls and mid-rolls in HLS - WWDC21](https://developer.apple.com/videos/play/wwdc2021/10140/)
> * [ What’s new in HLS Interstitials - WWDC22](https://developer.apple.com/videos/play/wwdc2022/10145/)

## HLS Interstitials support in AdswizzSDK

The HTTP Live Streaming (HLS) protocol delivers live and on-demand audiovisual content. Vendors typically insert separate interstitial content into their primary presentations in order to display advertising, branding, or other information to viewers. 
The **_AdswizzSDK v7.10.2_** HLS interstitial support is able to sync with the **_AdManager_** (obtained in the client side scenario) for features such as ad tracking, reporting, companion banners support and certified audibility, as well as more advanced experiences that are difficult to achieve with earlier techniques, such as late binding to current ad inventory and dynamic scheduling.

This type of ad insertion refers to the scenario in which your application **plays a HLS stream** and through a public dedicated interface detailed below, it can **link the interstitial player to the AdManager**, so that **_AdswizzSDK_** can automatically track the ads playback (with the added responsibility of accurate tracking and reporting) and sync to the interstitial player for the current **AVPlayerInterstitialEvent** (available from iOS 15 and later).

> To learn more, read Apple's [HLS Specification and Implementation Guide](https://developer.apple.com/streaming/GettingStartedWithHLSInterstitials.pdf).

### Introducing AdInterstitialEventMonitor

**_AdswizzSDK v7.10.2_** introduces **_AdInterstitialEventMonitor_** protocol - a public interface which aims to act as a bridge between **AdManager** and the native **AVPlayerInterstitialEventController**.

```swift
/// The `AdInterstitialEventMonitor` interface provides native support while playing ads from `AdManager`.
/// It is designed to add interoperability between the `AdManager` it is set on and the native `AVPlayerInterstitialEventController` for scheduling and monitoring HLS interstitial events.
/// Read more about `AVPlayerInterstitialEventController` at https://developer.apple.com/documentation/avfoundation/avplayerinterstitialeventcontroller 
@objc(AASDKAdInterstitialEventMonitor) public protocol AdInterstitialEventMonitor {
     
    /// The native player (provided by the `AVPlayerInterstitialEventController`) which plays the ads during an `AVPlayerInterstitialEvent`.
    @objc var interstitialPlayer: AVQueuePlayer { get }
 
}
```

The **_AdInterstitialEventMonitor_** is required to be set on the **_AdManagerSettings_** of the AdManager that drives the associated `AVPlayerInterstitialEvent`:
```swift
/// The `AdManagerSettings` class provides settings to configure an instance of `AdManager`.
@objc(AASDKAdManagerSettings) public final class AdManagerSettings: NSObject {
     
    ...
 
    /// Set the interstitial event monitor that provides support for playing the ads during a HLS interstitial event (ad break).
    /// This will instruct the `AdManager` to play the ads which were previously set as template items when the interstitial event is triggered.
    /// If you have your own custom implementation for HLS interstitials, use the `player` property instead (and set your interstitial player as external player instance that conforms to the `MediaPlayerState` protocol).
    @objc public weak var adInterstitialEventMonitor: (any AdInterstitialEventMonitor)?
 
    ....
}
```

### How to use AdInterstitialEventMonitor

The new interface API is designed to mirror the `AVPlayerInterstitialEventController`. In your application, you only need to conform to the **_AdInterstitialEventMonitor_** protocol:
```swift
import AVFoundation
// `AVPlayerInterstitialEventController` inherits from `AVPlayerInterstitialEventMonitor`, so conforming
// the monitor covers both. `@retroactive` is required from `v8.0.0` onwards, because both the type and
// the protocol are declared in other modules.
extension AVPlayerInterstitialEventMonitor: @retroactive AdInterstitialEventMonitor {}
```
...and set the `AVPlayerInterstitialEventController`  instance to the **_AdManagerSettings_** before passing to the **_AdManagerSettings_**.
```swift
let primaryPlayer: AVPlayer = ...
let controller = AVPlayerInterstitialEventController(primaryPlayer: primaryPlayer)
 
...
 
// Obtain the AdManager instance
let adManager: AdManager = ...
adManager.delegate = self
 
// Pass the controller in AdManagerSettings
let settings = AdManagerSettings()
settings.adInterstitialEventMonitor = controller
 
// Set the adManagerSettings
adManager.adManagerSettings = settings
 
// Let the adManager prepare the ads and it will automatically start tracking and reporting during the HLS interstitial event
adManager.prepare()
```

> Note that your application is required to keep a **strong reference** to both the **_AdManager_** and the **_AdInterstitialEventMonitor_** instances **before** and **during** the HLS interstitial event, because `AdManagerSettings.adInterstitialEventMonitor` is a `weak` property.

> Since **_AdswizzSDK_** `v8.0.0` the **_AdManager_** and its settings are `@MainActor` isolated, so the type that owns them (a `UIViewController` already qualifies) must be `@MainActor` too, and its **_AdManagerDelegate_** / **_AdManagerInterstitialEventDatasource_** conformances must be isolated. See the [v8.0.0 migration guide](/iOS/SDKMigrations/v8_0_0.md).

You are now ready to schedule an `AVPlayerInterstitialEvent` onto the HLS primary player timeline.

### Scheduling an AVPlayerInterstitialEvent

Once you've obtained the **_AdManager_** which will drive the ad break, you can now schedule an `AVPlayerInterstitialEvent` to play the ads when it is triggered.
```swift
...

let adPodTemplates = adManager.avPlayerItems
let event = AVPlayerInterstitialEvent(primaryItem: primaryPlayer.currentItem!,
                                      identifier: "myEvent",
                                      date: Date().addingTimeInterval(5),
                                      templateItems: adPodTemplates,
                                      restrictions: [],
                                      resumptionOffset: .zero)
controller.events = [event]
}

...

@MainActor
extension AdManager {

    var allMediaFilesURLs: [URL] {
        return self.ads.compactMap { adData in
            guard let mediaURL = adData.asset.mediaUrl, let url = URL(string: mediaURL) else {
                return nil
            }
            return url
        }
    }
    
    var avPlayerItems: [AVPlayerItem] {
        return allMediaFilesURLs.map { return AVPlayerItem(url: $0) }
    }
}

```
Notice how the `templateItems` from the `AVPlayerInterstitialEvent` match the **ads creatives** from the **_AdManager_**.
When the `AVPlayerInterstitialEvent` is triggered by the `AVPlayerInterstitialEventController`, the associated **_AdManager_** will start tracking ads playback and notify its delegate in the same way as with the client side insertion scenario.

## HLS interstitial event lifecycle

The diagram below shows the **_AdManager_** states for a HLS interstitial event lifecycle.

<img src="/img/HLSInterstitialState.png" width="1500" />

## Other considerations

Note that the **interstitial player** (an instance of `AVQueuePlayer`) provided by the native `AVPlayerInterstitialEventController` will be handled behind the scene as an **internal player**.

Your application can control the playback (actions such as `pause()` or `resume()`) either via the **_AdManager_** instance or by using the **_interstitialPlayer_** instance itself (by calling `AVPlayer` specific methods such as `play()`, `pause()`, `setRate(0)`, etc.). However it is recommended to use the **_AdManager_** designated methods.

Additionally, you can rely on **_AdManagerDelegate_** and **_AdManagerDatasource_** for playhead updates and adDuration as well as for the **_AdEvents_** which normally are emitted by the **_AdManager_** instance.

Also, please note that due to the nature of the interstitial `AVQueuePlayer` provided by the `AVPlayerInterstitialEventController` being a shared player, if your application schedules multiple interstitial events, you should not call prepare() for all the associated **_AdManagers_** at the same time. Instead, you should only prepare the **_AdManager_** which is associated with the **upcoming** interstitial event.<br>
Thus, once that event is consumed and the associated **_AdManager_** has completed all ads, you can prepare the next **_AdManager_** and so on.

