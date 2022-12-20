# Open Measurement in AdswizzSDK

The **_AdswizzSDK_** includes the [Open Measurement SDK](https://iabtechlab.com/standards/open-measurement-sdk/), an industry standard developed by the IAB and designed to enable third-party viewability and verification measurement for audio and video ads served through VAST servers. **_Open Measurement_** is enabled by default in the AdswizzSDK and ads must be configured to traffic the **_<AdVerifications>_** node in their VAST container. Additionally, refrain from covering the **_AdVideoView_** container with any overlays (transparent or opaque), since these are taken into account by the OM SDK, and marked as obstructions, thus affecting viewability and reporting.
For more info on how to register your overlays as "friendly" obstructions by using **_AdVideoFriendlyObstruction_** objects, see [Viewability](/SDKiOS/VideoAds#viewability).

## Video controls as obstructions

Video controls such as pause buttons and progress bars provide important playback information to your users. On mobile, it is common practice to render large, touch-friendly controls over the container that renders video content. When using the **_AdswizzSDK_**, one way to show these controls is by adding them above the **_AdVideoView_** container. Usually, the controls are child elements of this view that covers (even partially) the underlying video player.
When video ad viewability is calculated through the Open Measurement SDK, all views overlaying the video content are considered obstructions and reduce the viewability rate. If an overlay (even fully transparent) sits above the entire video ad view, it is possible for inventory to be declared completely unviewable.
The Open Measurement SDK allows for video controls to be considered "friendly" obstructions that contribute to the user’s experience. Once registered as "friendly", these controls are excluded from ad viewability measurement.

Here are some examples of elements that are appropriate to register as friendly obstructions:
  * transparent overlays used to capture user taps
  * playback buttons
    + pause
    + play
    + skip
    + fullscreen
    + minimize
    + Cast/Airplay
    + progress/seek
  * other controls relevant to playback

Elements like pop-ups or dialogs are not usually registered.
