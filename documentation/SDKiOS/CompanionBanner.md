# Companion banner support

The AdswizzSDK lets you configure companion banner(s) if your Integration Manager provides you with a companion zone id.
Additionally, you can find more details on how to customize the behaviour of companion banners in the [Companion banner](/SDKiOS/GeneralSettings#companion-banner) section from [AdswizzSDK general settings](/SDKiOS/GeneralSettings).


## Adding an AdCompanionView

Companion views can be added from storyboard/xib when you add a view. Just specify the **_AASDKAdCompanionView_** ObjC class. You can also add the view programmatically. 
Once created, the SDK will keep track of all of your companion views and automatically fill them with ad related content as the ad is playing. By default, an **_AdCompanionView_** instance is inactive, meaning that as long as it's not visible on screen it won't load the content (during the ad break). You can temporarily "deactivate" companion view at any time by either hiding it, resizing it to .zero bounds or removing it from its superview(s). The SDK will automatically keep track of your companion state and stop or resume rendering.


## Setting things up

The **_AdCompanionView_** instance(s) you create work the same across all types of integrations, whether it is a client-side, server-side or podcasting scenario. However, the setup will differ depending on how you intend to use the **_AdswizzSDK_**. Let's see the different to prepare for your companion views to load the ad related content.

### Client side setup

When you create an **_AdswizzAdRequest_** object for the first time, you need to fill in the **_companionZones_** with the value provided by your Integration Manager.

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
              .with(companionZones: "COMPANION_PROVIDED_BY_INTEGRATION_MANAGER") //IMPORTANT: mandatory for loading content into AdCompanionView instances
              .build()
```

Once the request is made, if there is any companion banner associated with the ad, it will be loaded into your **_AdCompanionView_** object.

### Server side setup

When you create your **_AdswizzAdStreamManager_**, you need to fill in the **_companionZones_** with the value provided by your Integration Manager.
More details in the [Server-Side Insertion](/SDKiOS/ServerSideInsertion) section.

### Podcasts setup

Similar to the server-side scenario, when you create your **_AdswizzAdPodcastManager_**, you need to fill in the **_companionZones_** with the value provided by your Integration Manager. You can find more details in the [Getting started](/SDKiOS/Podcasts#getting-started) section for [Podcasts](/SDKiOS/Podcasts).

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
