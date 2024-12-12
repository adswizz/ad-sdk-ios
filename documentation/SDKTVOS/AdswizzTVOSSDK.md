# AdswizzSDK tvOS

This guide is for developers who want to integrate the **_AdswizzSDK_** into their tvOS applications, enabling rich audio ad experiences on Apple TV devices. This document provides an overview of the integration process, key features, and considerations when working with AdswizzSDK for tvOS.

## What is the AdswizzSDK for tvOS?
**_AdswizzSDK_** is a comprehensive framework designed to deliver high-quality, interactive audio ads. The tvOS support is included as a slice in the main binary framework, allowing developers to leverage the same AdswizzSDK framework for both iOS and tvOS, simplifying integration and maintenance.

The AdswizzSDK tvOS framework extends its capabilities to the Apple TV platform by enabling seamless streaming and management of rich audio ads on Apple TV. It ensures a unified experience on both iOS and tvOS platforms to deliver consistent ad experiences across devices.

## SDK initialization and setup

The **_AdswizzSDK_** tvOS framework uses the same integration mechanism as on iOS, so to properly integrate the AdswizzSDK into your app, you first need to initialize the AdswizzSDK with an optional configuration.
There are two mandatory string settings that allow AdswizzSDK to be initialized properly: **_installationId_** and **_playerId_**. 
**_appStoreId_** is optional. If not provided, during initialization the SDK will attempt to fetch it remotely using Apple's public lookup API.

You can either set them in your Info.plist file with the **_AdswizzAdSDKInstallationId_** key, **_AdswizzAdSDKPlayerId_** and **_AdswizzAdSDKAppStoreId_** respectively (see [Changes in your Info.pList file](#changes-in-your-infoplist-file)), or set them programmatically in which case the Info.plist values will be overridden.

To programmatically set the **_installationId_**, **_playerId_** and **_appStoreId_** string settings you use a configuration object which is an instance of **_AdswizzSDKConfig_**.

Note that there is also a `completion` block available for the `initialize()` method. It is optional but it indicates precisely when the **_AdswizzSDK_** has completed the initialization. The `completion` block is always called on the main thread.

The recommended place to initialize the AdswizzSDK is in your **_AppDelegate_** class on **_didFinishLaunchingWithOptions_** function. Here is a snippet of what this might look like:


```swift
import UIKit
import AdswizzSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
......
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  //the configuration object is optional, unless you want to override the Info.plist values
  //or simply didn't add the string settings in your app's Info.plist
  let config = AdswizzSDKConfig(playerId: "yourPlayerId", installationId: "yourInstallationId", appStoreId: "yourAppAppleID")
  do {
     try AdswizzSDK.shared.initialize(with: config, completion: { [weak self] in //completion block is optional
        print("AdswizzSDK is initialized")
     })
  } catch {
     print(error)
  }
.......
}
.......
}
```
