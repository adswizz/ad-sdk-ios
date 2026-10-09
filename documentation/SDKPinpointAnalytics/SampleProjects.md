# Sample projects

The best way to see the **_AdswizzSDKPinpointAnalytics_** in action is by studying the example projects included in the `/Samples` folder. Download the `/Samples` folder using the below `git` command:
```properties
$ git clone https://github.com/adswizz/ad-sdk-ios.git
 ```

The examples are structured as separate projects in the _**Examples.workspace**_. Note that the samples workspace uses Cocoapods to install **_AdswizzWatchSDK_**, **_AdswizzSDK_** and, **_AdswizzSDKPinpointAnalytics_**. To successfully build and run the samples, you first need to run a `pod install` to make sure all the necessary dependencies are downloaded and resolved properly.
Next, open _**Examples.workspace**_ and run each sample individually by selecting the appropriate target and clicking 'Run' in XCode.

## BasicAnalyticsExample

This sample demonstrates how to use **_AdswizzSDKPinpointAnalytics_** in your application.
It shows how to create an **_AdswizzPinpointConnector_** and add it to AdswizzSDK's pool of connectors. The example simply requests an ad from the Adswizz servers, plays the ad and prints all the Analytics events that the **_AdswizzSDK_** logs.

The example also demonstrates a basic implementation of a custom **_AnalyticsConnector_** interface to be able to intercept and print events.