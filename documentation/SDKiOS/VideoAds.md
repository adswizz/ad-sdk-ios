# Video ads

The AdswizzSDK is capable of handling video content when an ad server delivers video ads. There are a couple of steps needed to make sure that your users are presented with the video content when playing video ads.

## Adding an AdVideoView

**_AdVideoView_** is an instance of **_UIView_** responsible for rendering video content during video ad playback. Just like companion views, a video view can be created either programmatically or through storyboard/xib when you add a plain view. If you're using of a storyboard, make sure to specify the **_AASDKAdVideoView_** ObjC class. 

Once created, you have ownership over this view and you can add it to your hierarchy like any other UI component.

## Setup video support

The first step is to let the SDK know that you wish to render video content when video ads are played. To do that, you'll need to pass an instance of **_AdVideoView_** when setting up Ad Manager (after it was obtained following an Ad Request) via **_AdManagerSettings_**. For more details see [Setup AdManager](/iOS/SDKiOS/ClientSideInsertion#setup-admanager).

The video view instance doesn't have to be visible / added to your hierarchy at this point, but remember that you own the video view instance and it is your responsibility to keep track of it.

The next step is to decide when to present / dismiss the video view. Video rendering in **_AdVideoView_** is synced with the actual ad playback. This means that you can use the ad events from **_AdManagerDelegate_**. See an example below:

```swift
import AdswizzSDK

class YourModelClass: AdManagerDelegate {
   var adManager: AdManager?
......
func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
    switch event.event {
      case .readyForPlay:
            // Check if current ad is video
            if let ad = event.ad, ad.adType == .video {
                // Now would be the time to show your AdVideoView instance
                //...
            }
           adManager.play() //Start playing the next ad in the AdManager
      case .adCompleted:
            // Check if current ad is video
            if let ad = event.ad, ad.adType == .video {
                // Now you should hide your AdVideoView instance
                //...
            }
            // Current ad has finished playing
      case .allAdsCompleted:
            break // All ads from the AdManager have finished
      default:
          break
    }
}
......
}
```

The **_AdVideoView_** will render video content during the video ad playback. After the video ad has finished playing, the video view may be dismissed.
You can only set one **_AdVideoView_** instance on an Ad Manager, but you can reuse the same video view instance for multiple Ad Managers.

## Subclassing AdVideoView

**_AdVideoView_** can be subclassed and used just like any other **_UIView_** based component. However, you should not tamper with the private and internal subviews managed by the SDK. Nor should you disable user interaction on **_AdVideoView_** because by doing so you will prevent correct reporting of click-through or click trackings.


# Video events

There are no specific video events to respond to; however, you can set a delegate to your **_AdVideoView_** instance that conforms to the **_AdVideoViewDelegate_** protocol. Just like companion views, you will be notified to decide whether or not to override the click-through target URL on the video view. 

# Viewability

Viewability enables the AdswizzSDK to allow third-party verification measurement for both audio and video ads. See [Open Measurement in AdswizzSDK](/iOS/SDKiOS/OpenMeasurement) for more details.

## Friendly obstructions

When any native elements are part of the **_AdVideoView_** container, such as a skip button, some logo text, or other kind of overlay, you should register them as "friendly" obstructions to prevent them from counting towards coverage of the video ad during playback. This applies to any ancestor or peer views in the **_AdVideoView_** hierarchy, and all subviews of this view will be automatically treated as part of the ad.

Once you've identified such elements that should be marked as friendly, you can create an **_AdVideoFriendlyObstruction_** object by passing, in the **_view_** that is causing the obstruction, a **_purpose_** (see `AdVideoFriendlyObstructionPurpose` enum for all possible cases) and an optional **_detailed reason_**. After that, just
register the newly created obstruction object to your **_AdVideoView_** instance.


```swift
import UIKit
import AdswizzSDK

var videoView: AdVideoView?
.....

let closeButton = UIButton()
videoView.addSubview(closeButton)
.....

let obstruction = AdVideoFriendlyObstruction(view: closeButton,
                                          purpose: .closeAd,
                                   detailedReason: "Close button")
videoView.register(obstruction)

```

When you're done with them, these obstructions can be removed by calling:

```swift
videoView.unregisterAllFriendlyObstructions()
```

## Video player state

Rounding up the viewability support, AdswizzSDK enables you to communicate your **_AdVideoView_** video player state by using the **_AdVideoState_** property. Set the state whenever the video view transitions to one of the following:

### normal
The video view's default playback size.

### expanded
The video view has expanded from its original size.

### collapsed
The video view has been reduced from its original size. The video is still potentially visible.

### fullscreen
The video view has entered fullscreen mode.

### minimized
The video view is `collapsed` in such a way that the video is hidden. However, the ad has not been fully removed from the player environment. The video may or may not still be progressing in this state, and sound may be audible. Unlike the collapsed state, where the video view is big enough to display its content, in the minimized state the video view is only big enough to offer a control that enables your user to redisplay the ad if desired.
Note that the video view will automatically handle the app state change by setting the video `state` to `minimized` while the app is in the background. When the app becomes active again, the video view restores `state` to its previous value.


```swift
import UIKit
import AdswizzSDK

// Default state is .normal.
var videoView: AdVideoView?
.....

// When your video view transitions to another state (e.g fullscreen).
// Inform AdswizzSDK for any state change for viewability purposes.
videoView.state = .fullscreen

```

# Playing video ads using your player

When you play video ads with your own player conforming to **_MediaPlayerState_**, it is your responsibility to implement video rendering within **_AdVideoView_**. The recommended way is to implement your own **_UIView_** subclass with an **_AVPlayerLayer_** as backing layer, and add it below all other subviews from **_AdVideoView_**. Here is an example of how to acccomplish this:


```swift
import UIKit
import AVFoundation

class PlayerView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
......

class YourAdVideoView: AdVideoView {
    lazy var renderingView: PlayerView = {
        return PlayerView(frame: .zero)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Make sure your rendering view is added below all other views managed by AdVideoView
        insertSubview(playerView, at: 0)

        // Setup constraints for rendering view to cover the entire parent view
        // ...
    }
}

```

If you follow the approach above, remember to pass the **_YourAdVideoView_** instance when setting up **_AdManager_** through **_AdManagerSettings_**.
See [Playing ads using your player](/iOS/SDKiOS/ExternalPlayer#playing-ads-using-your-player) for more details on how to conform to **_MediaPlayerState_** protocol.
