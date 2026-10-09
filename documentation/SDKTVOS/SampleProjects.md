# Sample projects

The best way to see the AdswizzSDK in action is by studying the example projects included in the `/Samples` folder. Download the `/Samples` folder using the below `git` command:
```properties
$ git clone https://github.com/adswizz/ad-sdk-ios.git
 ```

The examples are structured as separate projects in the **_Examples.workspace_**. Note that the samples workspace uses Cocoapods to install the AdswizzSDK and the necessary dependencies. To successfully build and run the samples, you first need to run a `pod install` to make sure all the necessary dependencies are downloaded and resolved properly.
Next, open **_Examples.workspace_** and run each sample individually by selecting the appropriate target and clicking 'Run' in XCode.

## BasicTVOSExample

This sample demonstrates a basic client-side insertion scenario by showing how to create and customize an **_AdswizzAdRequest_**. It shows how to use it to create an **_AdRequestConnection_** and finally request ads. Next, it demonstrates basic usage of an instance of **_AdManager_** once it is obtained from the SDK. It also creates and displays an **_AdCompanionView_** while playing ad(s).
The sample attempts to simulate an app that plays its normal content and occasionally requests ads, pauses content, plays ads, and finally resumes playing normal content.

Additionally, it demonstrates a basic server-side insertion scenario by showing how to create and customize an **_AdswizzAdStreamManager_** for your tvOS app. It shows how to play/stop/pause/resume a live stream. 

Ultimately, it shows how your tvOS app can integrate the **_AdswizzSDK_** podcasting support by using an **_AdswizzAdPodcastManager_**. 
