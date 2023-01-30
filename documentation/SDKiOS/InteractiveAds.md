# Interactive ads

Apart from standard audio/video ads, the AdswizzSDK can also deliver interactive ads formats such as ShakeMe or Voice Ads.
To better understand these ads from a technical perspective, you can view them as standard audio ads with an "interactive" component on top.

## Handling interactive ads

Given that interactive ads are delivered the same way as normal audio/video ads, regardless of the integration scenario you are aiming for in your app, handling such ads does not require any specific setup other than what is expected for normal audio ads.

For example, in a [Client-Side Insertion](/SDKiOS/ClientSideInsertion) scenario, playing an interactive ad is still managed via an instance of **_AdManager_**. Your app will receive the same familiar events defined in the **_AdEventType_** enum for the ad's lifecycle.
In a [Server-Side Insertion](/SDKiOS/ServerSideInsertion) scenario, when an ad break is detected in your stream, you will still get an **_AdManager_** object containing the current running interactive ad.
In a [Podcasts](/SDKiOS/Podcasts) scenario, after a podcast starts playing, your app can still receive an **_AdManager_** object containing the (interactive) ads fetched from the Adswizz server.

However, interactive ads may require specific permissions on your app, depending on the type of action performed as a result of a positive user intent (successful shake or voice detection). Please refer to the [Changes in your Info.pList file](/SDKiOS/GetStarted#changes-in-your-infoplist-file) section to operate the necessary changes on your app's permissions.

Next, let's explore the two main types of interactive ads supported by AdswizzSDK.

## ShakeMe interactive ads

The AdswizzSDK is able to deliver ShakeMe interactive ads. During audio playback, these ads allow users to shake their device, which will prompt the SDK to perform a certain action (e.g play an extension to the current ad). Unlike voice interactive ads, ShakeMe ads do not require any permission to be properly rendered. Shake detection works regardless of the app is in the foreground or background. However, if the action performed as a result of the shake requires a specific permission (e.g save a calendar event), your app must request that permission.

## Voice enabled interactive ads

The AdswizzSDK is able to deliver interactive voice ads with the ability of voice detection while the app is in _foreground_.
To be able to fetch and play voice ads, your app should first obtain the following user permissions:
* **microphone** - used for voice recording
* **speech** - used for the speech-to-text transcriber
These permissions are **_mandatory_** to be able to properly render voice ads. See [Changes in your Info.pList file](/SDKiOS/GetStarted#changes-in-your-infoplist-file) section for the necessary changes on these permissions in your app.

### Handling voice recording

Apple recommends that your app’s UI reflect when recording starts or stops. The AdswizzSDK provides a way to notify your app that recording has begun or stopped:


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

While the **_AdMangerDelegate_** object provides a list of events through **_AdEventType_** covering the life cycle of an ad, it does not provide interactivity-related information for interactive ads.
To get more insight into what is happening while an interactive ad is playing, you can set the **_interactiveDelegate_** on the **_AdManager_** object.

### InteractiveAdManagerDelegate

#### func interactiveAdManager(_ adManager: AdManagerOwner, didReceiveAdEvent event: InteractiveAdEvent)

Called when there is an interactive event with the current ad in the **_AdManager_**. Note that **_AdManagerOwner_** is just an alias for the **_AdManager_**. See the **_InteractiveAdEvent_** enum for all possible values.

#### func interactiveAdManager(_ adManager: AdManagerOwner, shouldPresentCoupon pkpassData: Data)

Called immediately after the coupon has been downloaded as a result of a shake event or voice positive intent. It gives your app the chance to react and present the **_PKAddPassesViewController_** from UIKit. This callback is always triggered on the main thread.

Next, here is an example of what the **_InteractiveAdManagerDelegate_** implementation may look like:

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

Notice that the code snippet above shows how to also handle coupons as PKPassData via **_InteractiveAdManagerDelegate_** in case the current interactive ad needs to save a coupon in the Wallet.
