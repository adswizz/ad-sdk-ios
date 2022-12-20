# Sample projects

The best way to see the **_AdswizzWatchSDK_** in action is by studying the example projects included in the `/Samples` folder. Download the `/Samples` folder using the below `git` command:
```properties
$ git clone https://github.com/adswizz/ad-sdk-ios.git
Username: adswizz-sdk
Password: your_access_token (provided by AdsWizz)
 ```

The examples are structured as separate projects in the _**Examples.workspace**_. Note that the samples workspace uses Cocoapods to install **_AdswizzWatchSDK_**, **_AdswizzSDK_** and, the necessary dependencies. To successfully build and run the samples, you first need to run a `pod install` to make sure all the necessary dependencies are downloaded and resolved properly.
Next, open _**Examples.workspace**_ and run each sample individually by selecting the appropriate target and clicking 'Run' in XCode.

## BasicAdRequestWatchExample

This sample demonstrates how to use **_AdswizzWatchSDK_** in the WatchOS companion app.
It shows how the main app project communicates through a watch extension, using messages, and updates a status label on the watch mirroring events happening in the iOS companion app.

### Getting started

The sample uses a basic approach to show how to structure your app project with a WatchOS extension:
* **_BasicAdRequestWatchExample_** encapsulates the main app project
* **_BasicAdRequestWatch_** encapsulates the interface for the watch extension
* **_BasicAdRequestWatch Extension_** encapsulates the logic for the watch extension

### Running the sample

To get the most out of the sample, you should ideally run it with actual devices (both iOS and WatchOS). This way, you will be able to interact with the watch when interactive ads are being played on the iOS companion app.
Also note the usage of [Now Playing](https://developer.apple.com/documentation/mediaplayer/becoming_a_now_playable_app) in **_BasicAdRequestWatchExample_**. When an interactive ad is being played, it allows the iOS companion app to wake up the watch extension and take action on the watch itself (e.g shake the watch, use speech-to-text for voice ads, etc.).

