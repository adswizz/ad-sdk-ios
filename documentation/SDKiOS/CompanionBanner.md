# Companion banner support

The AdswizzSDK lets you configure companion banner(s) if your Integration Manager provides you with either a companion zone id or alias.
Additionally, you can find more details on how to customize the behaviour of companion banners in the [Companion banner](iOS/SDKiOS/GeneralSettings#companion-banner) section from [AdswizzSDK general settings](iOS/SDKiOS/GeneralSettings).


## Adding an AdCompanionView

Companion views can be added from storyboard/xib when you add a view. Just specify the **_AASDKAdCompanionView_** ObjC class. You can also add the view programmatically. 
Once created, the SDK will keep track of all of your companion views and automatically fill them with ad related content as the ad is playing. By default, an **_AdCompanionView_** instance is inactive, meaning that as long as it's not visible on screen it won't load the content (during the ad break). You can temporarily "deactivate" companion view at any time by either hiding it, resizing it to .zero bounds or removing it from its superview(s). The SDK will automatically keep track of your companion state and stop or resume rendering.


## Setting things up

The **_AdCompanionView_** instance(s) you create work the same across all types of integrations, whether it is a client-side, server-side or podcasting scenario. However, the setup will differ depending on how you intend to use the **_AdswizzSDK_**. Let's see the different ways to prepare for your companion views to load the ad related content.

### Client side setup

When you create an **_AdswizzAdRequest_** object for the first time, on the **_AdswizzAdRequest.Builder_** object, you need to call either the `.with(companionZoneIds: [Int])` method or `.with(companionZoneAliases: [String])` by passing the appropriate value(s) provided by your Adswizz Integration Manager.

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

adRequest = try AdswizzAdRequest.Builder()
              .with(server: "SERVER_PROVIDED_BY_INTEGRATION_MANAGER")
              .with(zone: zone)
              // IMPORTANT: mandatory for loading content into AdCompanionView instances 
              .with(companionZoneIds: [COMPANION_ZONE_ID_PROVIDED_BY_INTEGRATION_MANAGER]) //mutually exclusive with companionZoneAliases
              .with(companionZoneAliases: ["COMPANION_ZONE_ALIAS_PROVIDED_BY_INTEGRATION_MANAGER"]) //mutually exclusive with companionZoneIds
              .build()
```

> Similarly to the `with(zones: [AdswizzAdZone])` method, the order in which you pass the companion zone ids or aliases is important, as the AdsWizz Ad Server will take that into account during companion banner content selection.

> Note that the `.with(companionZoneIds: [Int])` and `.with(companionZoneAliases: [String])` methods are mutually exclusive. You should only set one or the other, not both. Otherwise the **_AdswizzAdRequest.Builder_** will throw an error.
The `.with(companionZones: String?)` method has been *deprecated* in **AdswizzSDK v7.12.0** and will be removed in a future release.

Once the request is made, if there is any companion banner associated with the ad, it will be loaded into your **_AdCompanionView_** object.

### Server side setup

When you create your **_AdswizzAdStreamManager_**, you need to fill in the **_companionZones_** with the value provided by your Integration Manager.
More details in the [Server-Side Insertion](/iOS/SDKiOS/ServerSideInsertion) section.

### Podcasts setup

Similar to the server-side scenario, when you create your **_AdswizzAdPodcastManager_**, you need to fill in the **_companionZones_** with the value provided by your Integration Manager. You can find more details in the [Getting started](/iOS/SDKiOS/Podcasts#getting-started) section for [Podcasts](/iOS/SDKiOS/Podcasts).

## Companion data

If available, **_AdswizzSDK_** provides access to companion data through the **_Companion_** protocol associated to each **_AdData_** instance that has any companion banner content to display.
The **_Companion_** protocol encapsulates and exposes information from the VAST response itself - and packaged by the **_AdManager_**.

```swift
import AdswizzSDK

@MainActor
class YourModelClass: @MainActor AdManagerDelegate {
   var adManager: AdManager?
.....
func didReceiveResponse(_ adManager: AdManager?, _ error: Error?) {
    ......
    self.adManager = adManager   // Keep a strong reference of this object
    adManager?.delegate = self   // Get notifications from the Ad SDK
    
    ......
    // Complete the setup on the adManager instance as needed by setting an appropriate AdManagerSettings()
    ......

    adManager?.prepare()   // Start buffering the ads in the AdManager
}
......

......
func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
    switch event.event {
      case .preparingForPlay:
           // This is the earliest point in the ad events succession where you can inspect the companion banner information if available.
           // However, you can also inspect this information on other ad events such as .readyForPlay or .didStartPlaying
           print("hasCompanion = \(event.ad?.hasCompanion ?? false)")
           print("selected companion width = \(event.ad?.selectedCompanion?.width) height = \(event.ad?.selectedCompanion?.height)")

      default:
          break
    }
}
......
}
```

Next, let's explore further the companion data accessible from the **_AdData_** instance.

### companions

The list of available **_Companion_** instances associated with the **_AdData_**. May be empty if the ad does not have any companion data associated with the ad.
May not be available when the ad is preparing/ready to play or has just started playing. Take a look below at the **_hasCompanion_** property instead to check for the presence of any companion data.

### hasCompanion

Determines if the ad has any companion banner information to display. Note that this information is available early in the succession of ad events and it can be used to update your UI accordingly. For example, in case **_hasCompanion_** returns `false`, you may want to swap the **_AdCompanionView_** with a placeholder or remove the companion view container altogheter.

### selectedCompanion

The **_Companion_** instance which will be displayed when the ad starts. The selection is based based on various criterias such as setting the [preferred resource type](/iOS/SDKiOS/GeneralSettings#preferred-resource-type).

For more details on how and when the **_Companion_** data might be useful, please read the [Companion best practices](#companion-best-practices) section below.

## Companion events

You can associate a delegate to your **_AdCompanionView_** object that conforms to the **_AdCompanionViewDelegate_** protocol. You will be notified when the ad loaded the companion view, if the companion view was displayed, or if it ended the display. If there was an error while loading the companion banner, you will be notified through this delegate. Also, you can decide whether or not to override the click-through target URL on the companion banner. 

### AdCompanionViewDelegate

#### func adCompanionViewWillLoad(_ adCompanionView: AdCompanionView)

Called when the **_AdCompanionView_** is about to load its content.

#### func adCompanionViewDidDisplay(_ adCompanionView: AdCompanionView)

Called when the **_AdCompanionView_** displayed its content on screen.

#### func adCompanionViewDidEndDisplay(_ adCompanionView: AdCompanionView)

Called when the **_AdCompanionView_** finished displaying its content.

#### func adCompanionView(_ adCompanionView: AdCompanionView, didFailToDisplay error: Error)

Called when the **_AdCompanionView_** failed to load its content. The failure is normally due to network connectivity issues.

## Companion best practices

When you create an **_AdCompanionView_** instance, **_AdswizzSDK_** will start monitoring the companion view lifecycle and render the associated content during the ad playback. It begins to communicate to its delegate via **_AdCompanionViewDelegate_** protocol detailed above. The communication focuses on updates for content loading / displaying by the **_AdCompanionView_** and your model should listen for any such incoming signals and act accordingly. i.e perform any further UI updates if needed, listen for errors to be able to display placeholders, etc.

> **Note**
> You can create and display multiple **_AdCompanionView_** instances in your application within different view hierarchies. **_AdswizzSDK_** will render the **same** ad related content for all companion banner instances while an **_AdManager_** starts playing the ads.

Note that it is your responsability to keep a **strong** reference the **_AdCompanionView_** instances that you create in your application (although, this is typically achieved by default when you add the companion view(s) to your own view hierarchy in your app).

Here are a few things to consider when working with the **_AdCompanionView_**:
* content is loaded and rendered within an **_AdCompanionView_** only if the view is considered **visible** on screen. The visibility checks performed by the **_AdswizzSDK_** include but not limited to:
    - UIView properties such as `alpha`, `isHidden`
    - finite size e.g non-zero `bounds` or `frame`
    - valid UIWindow attached
    - within `superview` bounds
* an ad break can contain multiple ads (e.g the **_AdManager_** instance contains multiple **_AdData_** objects) and the content is updated seamless across all your *active* `AdCompanionView` instances. *Therefore, there is no need to re-create the `AdCompanionView` instance(s) during ads lifecycle from the **_AdManager_**.*
* it is not mandatory to implement any of the callbacks for the **_AdCompanionView_** from the **_AdCompanionViewDelegate_** protocol. Setting a delegate on your **_AdCompanionView_** instance is completely optional, however, keep in mind that this is your only communication channel with the **_AdCompanionView_** when it comes to content rendering.
* in some cases, the **_AdCompanionView_** may inform your app that an error occured via the `adCompanionView(_ adCompanionView: AdCompanionView, didFailToDisplay error: Error)` delegate method from **_AdCompanionViewDelegate_** protocol. It is considered best practice to implement this method so that your application is well aware of any such error. When an error is received, you may want to show a placeholder instead of the empty companion view or remove it entirely from your views hierarchy.
* if you prefer `SwiftUI` over `UIKit`, we highly encourage you to take a look at the [BasicSwiftUIClientSideInsertion](iOS/SDKiOS/SampleProjects#basicswiftuiclientsideinsertion) sample which shows how to best handle UI components such as `AdCompanionView` and `AdVideoView` in a SwiftUI app. The sample also includes recommendations on how to use animations with **_AdCompanionView_** components.
* you may want to resize the **_AdCompanionView_** container based on the **VAST aspect ratio** directives. To determine the appropriate size, use the `width` and `height` properties of the [selectedCompanion](#selectedcompanion) accessible from the **_Companion_** object in its associated **_AdData_** and compute the aspect ratio. Then apply it to your **_AdCompanionView_** container so that the content will fit your desired size without unwanted stretching or clipping.
* in some cases, especially in layouts written in `SwiftUI`, you may need to instruct the **_AdCompanionView_** to recheck its visibility constraints. Calling the `activateIfNeeded()` method on your **_AdCompanionView_** instance will force it to evaluate visibility if it is not already "active". If it passes all visibility checks, the companion view is considered "activated" and renders its content during the ad break.


