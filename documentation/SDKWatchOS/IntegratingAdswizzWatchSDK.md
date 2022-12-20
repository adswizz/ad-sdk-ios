# Integrating AdswizzWatchSDK
## Prerequisites

*   Xcode 10+
*   Swift 5.0+ if the integration app uses Swift, or Objective-C
*   Framework binaries - via CocoaPods

## Adding the SDK to your Xcode project
**_AdswizzWatchSDK_** is delivered as an xcframework, so the best way to integrate it is through Cocoapods. The recommended version for Cocoapods is 1.9.3 or later. If you already have a pod file, you just need to add the following line in your watch extension target:

```ruby
    pod 'AdswizzWatchSDK', :git => "https://github.com/adswizz/ad-sdk-ios.git"
```
 
After modifying the podfile, run `pod install`. You will be prompted to enter the security credentials to access the AdswizzSDK repository. You can obtain the credentials from your AdsWizz partner integration manager. Once authorization is successful, the framework will be installed.

## SDK integration
**_AdswizzWatchSDK_** doesn't need to be initialized.

### Watch Extension state
**_AdswizzWatchSDK_** needs to be informed of the state of your WatchOS extension. Here is how you can do that in the ExtensionDelegate class:

```swift
import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    //Wrapper around WCSessionDelegate
    private lazy var sessionDelegate: SessionDelegate = {
        return SessionDelegate()
    }()

    override init() {
        super.init()
        // Activate the session asynchronously as early as possible.
        // In the case of being background launched with a task, this may save some background runtime budget.
        //
        WCSession.default.delegate = sessionDelegate
        WCSession.default.activate()
    }

    func applicationDidBecomeActive() {
        //notify AdswizzWatchSDK that extension is active
        AdswizzWatchSDK.shared.applicationDidBecomeActive()
    }

    func applicationWillResignActive() {
        //notify AdswizzWatchSDK that extension will be inactive
        AdswizzWatchSDK.shared.applicationWillResignActive()
    }

    func applicationWillEnterForeground() {
        //notify AdswizzWatchSDK that extension will enter foreground
        AdswizzWatchSDK.shared.applicationWillEnterForeground()
    }
    
    func applicationDidEnterBackground() {
        //notify AdswizzWatchSDK that extension entered background
        AdswizzWatchSDK.shared.applicationDidEnterBackground()
    }
}
```
Calling these **_AdswizzWatchSDK_** APIs is essential for communication between the **_AdswizzSDK_** and **_AdswizzWatchSDK_** .

Next, you need to link your **_WCSessionDelegate_** object to be notified by **_AdswizzWatchSDK_** or the **_AdswizzSDK_** about watch messages you have to send to the other side.

```swift
#if os(iOS)
    let watchSession: WatchSession = AdswizzSDK.shared.watchSession.setDelegate(self)
#elseif os(watchOS)
    let watchSession: WatchSession = AdswizzWatchSDK.shared.watchSession.setDelegate(self)
#endif
```
This code is common between iOS and WatchOS, and can be treated in the same file, which can be shared between your iOS app and your WatchOS extension.
Here is the setup of this common SessionDelegate class:

```swift
import Foundation
import WatchConnectivity
#if os(iOS)
import AdswizzSDK
#elseif os(watchOS)
import AdswizzWatchSDK
#endif

class SessionDelegate: NSObject {
#if os(iOS)
    let watchSession: WatchSession = AdswizzSDK.shared.watchSession
#elseif os(watchOS)
    let watchSession: WatchSession = AdswizzWatchSDK.shared.watchSession
#endif
    
    override init() {
        super.init()
        //set this object to handle WatchSessionDelegate
        watchSession.setDelegate(self)
    }
 }
```

### Forwarding messages from WCSession to AdswizzWatchSDK/AdswizzSDK
In the SessionDelegate class, we need to conform to WCSessionDelegate to handle two APIs that AdsWizz uses to send messages from iOS to WatchOS and vice-versa. Remember, this code is common to iOS (**_AdswizzSDK_**) and WatchOS (**_AdswizzWatchSDK_**).

```swift
extension SessionDelegate: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //inspect the data
        //If it is from AdsWizz SDK, forward it to the WatchSession
        if message.isAdswizzWatchData {
            watchSession.receivedMessage(message)
        }
        //handle your data
        ....
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        //inspect the data
        //If it is from AdsWizz SDK, forward it to the WatchSession
        if applicationContext.isAdswizzWatchData {
            watchSession.receivedMessage(applicationContext)
        }
        //handle your data
        ....
    }
}
```
The **_AdswizzSDK_**/**_AdswizzWatchSDK_** provides an utility to inspect WatchOS-related messages and see if there is a need to forward them to the SDK.

### Sending messages from AdswizzWatchSDK/AdswizzSDK to WCSession
In the SessionDelegate class, we need to conform to **_WatchSessionDelegate_** to send messages over the WCSession default object. When **_AdswizzSDK_**/**_AdswizzWatchSDK_** calls these functions, all states regarding the WCSession object will be verified internally in order to make the call.

```swift
extension SessionDelegate: WatchSessionDelegate {
    func sendMessage(_ data: [String : Any]) {
        //use sendMessage API to send a direct message to the other side.
        //The state of the WCSession was already verified internally in the SDK.
        WCSession.default.sendMessage(data, replyHandler: nil) { error in
            //log the error
        }
    }
    
    func updateApplicationContext(_ data: [String: Any]) {
        //use updateApplicationContext API to send the message.
        //The state of the WCSession has already been verified internally in the SDK.
        do {
            try WCSession.default.updateApplicationContext(data)
        } catch {
            //log the error
        }
    }
}
```

### Running your WatchOS companion app in the background
By default, most WatchOS companion apps will not run in the background, meaning the OS will not permit communication between iOS and WatchOS for your app. If, by any chance, you have registered your app to play music in the background or you are running a work-out session in your WatchOS extension, you can notify **_AdswizzWatchSDK_** that you are running in the background. This will help you provide better targeting capabilities.

```swift
  AdswizzWatchSDK.shared.runningInBackground = true // your  WatchOS is running in the background
```
