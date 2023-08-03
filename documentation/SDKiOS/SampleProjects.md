# Sample projects

The best way to see the AdswizzSDK in action is by studying the example projects included in the `/Samples` folder. Download the `/Samples` folder using the below `git` command:
```properties
$ git clone https://github.com/adswizz/ad-sdk-ios.git
Username: adswizz-sdk
Password: your_access_token (provided by AdsWizz)
 ```

The examples are structured as separate projects in the **_Examples.workspace_**. Note that the samples workspace uses Cocoapods to install the AdswizzSDK and the necessary dependencies. To successfully build and run the samples, you first need to run a `pod install` to make sure all the necessary dependencies are downloaded and resolved properly.
Next, open **_Examples.workspace_** and run each sample individually by selecting the appropriate target and clicking 'Run' in XCode.

## BasicAdRequestExample

This sample demonstrates a basic client-side insertion scenario by showing how to create and customize an **_AdswizzAdRequest_**. It shows how to use it to create an **_AdRequestConnection_** and finally request ads. Next, it demonstrates basic usage of an instance of **_AdManager_** once it is obtained from the SDK. It also creates and displays an **_AdCompanionView_** while playing ad(s).
The sample attempts to simulate an app that plays its normal content and occasionally requests ads, pauses content, plays ads, and finally resumes playing normal content.
Additionally, it shows a basic **_AdManagerDatasource_** protocol implementation for further customizing the **_AdManager_** object.

## BasicAdRequestExampleObjC

This is the sample from above, but fully written in Objective-C. It demonstrates that, even though the AdswizzSDK is a Swift framework, it can still be used in an Objective-C project.

## BasicAdStreamExample

This sample demonstrates a basic server-side insertion scenario by showing how to create and customize an **_AdswizzAdStreamManager_**. It shows how to play/stop/pause/resume a live stream. It also creates and displays an **_AdCompanionView_** during ad break(s).
Additionally, it demonstrates how to use an `AVPlayer` wrapper called **_ExternalMediaPlayer_** as an external custom player with **_AdswizzAdStreamManager_**. The **_ExternalMediaPlayer_** conforms to **_MediaPlayerState_**.

## BasicAdStreamExampleObjC

This is the sample from above, but fully written in Objective-C.

## ExternalPlayerExample

This sample demonstrates how to implement your external player using the **_MediaPlayerState_** protocol in order for the **_AdswizzSDK_** to work properly. Also, this sample shows how you can debug events in the SDK by using **_AdLogger_** with a verbose level.

## BasicVideoAdExample

This sample shows a basic approach to handling video ad playback and rendering by using an instance of **_AdVideoView_**. It also covers viewability support by showcasing basic usage for "friendly" obstructions and video player states.

## BasicTrackingPermissionExample

This sample demonstrates basic usage for **_TrackingPermissionController_** in the default configuration. It also shows how to customize the logo element with Dark Mode support.

## BasicEmptyAdsExample

This sample shows how to handle cases when an **_AdRequestConnection_** delivers an Ad Manager object with no ads to play.

## BasicDVRRequestExample

This sample shows how to perform DVR using  **_AdStreamManagerSettings_** to configure an **_AdswizzAdStreamManager_**  object. 

## BasicSwiftUIClientSideInsertion

This sample shows how to display all the various UI components from the **_AdswizzSDK_** in a SwiftUI app. The app contains 4 tabs. The Banner tab displays an **_AdswizzAdCompanionView_**. The InApp Notification shows an ad that allows various interaction types like performing a call or going to a specific location on the map. It uses the same code as the previous tab, with different zones for the ads. The Video tab shows a video ad. Last but not least, the Tracking Permissions tab demonstrates showing the built-in permissions UI component to get the user's consent for tracking.

## BasicPodcastExample

This sample shows how your app can integrate the **_AdswizzSDK_** podcasting support by using an **_AdswizzAdPodcastManager_**. It demonstrates how to download a podcast locally, as well as playing it from disk or remotely.

## BasicAnalyticsExample

This sample demonstrates how to use **_AdswizzSDKPinpointAnalytics_** in your application.
It shows how to create an **_AdswizzPinpointConnector_** and add it to AdswizzSDK's pool of connectors. The example simply requests an ad from the Adswizz servers, plays the ad and prints all the Analytics events that the **_AdswizzSDK_** logs.

The example also demonstrates a basic implementation of an **_AnalyticsConnector_** interface to be able to intercept and print events.
