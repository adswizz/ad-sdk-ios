# AdswizzWatchSDK

This guide is for iOS developers who want to integrate the **_AdswizzWatchSDK_** in their WatchOS companion apps, in order to extend the audio ad experience and interactivity on these devices.
You will find a quick overview below. More details will be provided for each scenario in their respective sections.

## What is the AdswizzWatchSDK?
**_AdswizzWatchSDK_** is an extension of the **_AdswizzSDK_**, specifically built for WatchOS (6.0+) companion apps that will enable you to use AdsWizz interactive ads on the listener's watch. **_AdswizzWatchSDK_** is dependent on the **_AdswizzSDK_** in order to work properly.

## What it does do
**_AdswizzWatchSDK_** enhances **_AdswizzSDK_** capabilities to deliver rich audio ads and engage with listeners in a context-relevant, non-intrusive manner. Thus, **_AdswizzWatchSDK_** relies on a good integration of the **_AdswizzSDK_**, version 7.0 or later.
If, for example, the **_AdswizzSDK_** has to play a ShakeMe ad on the phone, it will also sense 'shake-me' events on the watch, using **_AdswizzWatchSDK_**.
If the communication with the watch is viable, **_AdswizzWatchSDK_** will also collect some data from the listener to improve the targeting capabilities. Information collected on the watch will be listed below.

## What it doesn't do
**_AdswizzWatchSDK_** can't function without the **_AdswizzSDK_**. It can't request ads from an ad server, nor is it able to play media files. It won't make any network requests, and all its communication is with the **_AdswizzSDK_**. It is important to note that **_AdswizzWatchSDK_** is just an extension of the **_AdswizzSDK_**.

## Prerequisites for a successful integration
In order for the **_AdswizzSDK_** to use the **_AdswizzWatchSDK_** on the listener's watch, you need to make sure that your iOS app automatically opens the WatchOS companion app before the ad break starts. This requires your iOS app to update the [Now Playing](https://developer.apple.com/documentation/mediaplayer/becoming_a_now_playable_app) information. When updating Now Playing in the iOS app, your WatchOS companion app will be automatically started. To recap, here's a list of things to keep in mind when integrating **_AdswizzWatchSDK_**:
* make sure your app is compliant with [Now Playing](https://developer.apple.com/documentation/mediaplayer/becoming_a_now_playable_app)
* make sure you update Now Playing information every time an ad is about to be played. Ideally, you can sync it with the **_preparingForPlay_** event you receive with the **_AdManager_** object. This will increase the probability that your WatchOS companion app starts on the watch.
* make sure your companion app has not opted out for [Auto-launch Audio App](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/watchOSKeys.html)

## Cases when updating 'Now Playing' information from iOS won't start the WatchOS companion app
* If the user has launched another app on their watch and this app is in the foreground, WatchOS will not bring the corresponding WatchOS companion app to the foreground, even if the iOS app has updated the 'Now Playing' information.
* The user has set “Auto-Launch Audio Apps” to false in the WatchOS settings (Settings/General/Wake Screen).
