# Integrating AdswizzSDKPinpointAnalytics
## Prerequisites

*   Xcode 14+
*   Swift 5.6+ if the integration app uses Swift, or Objective-C
*   Framework binaries - via Cocoapods, Carthage or manually added

## Dependencies
**_AdswizzSDKPinpointAnalytics.xcframework_** depends on the following frameworks:
* AWSCore.framework

The **_AdswizzSDKPinpointAnalytics_** for iOS depends on *Amazon’s AWSCore* as an external library in order to implement the AWS Pinpoint service used by the [AdswizzSDK Analytics](/iOS/SDKiOS/AdswizzAnalytics).<br>
The dependency above is automatically added if you choose to integrate the **_AdswizzSDKPinpointAnalytics_** using Cocoapods. If you choose either the Carthage or the manual integration, you will have to provide it at link time.

## Adding the AdswizzSDKPinpointAnalytics to your Xcode project
**_AdswizzSDKPinpointAnalytics_** is delivered as an xcframework. You can install it either through Cocoapods, Carthage or by manually adding it to your Frameworks group in your project. 

### Cocoapods
The recommended version for Cocoapods is 1.9.3 or later. If you already have a .podfile, you just need to add the following line in your application target:

```ruby
    pod 'AdswizzSDKPinpointAnalytics', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git"
```

Replace **_ADSWIZZ_GITHUB_TOKEN_** with the token you received from AdsWizz. You can obtain a token from your AdsWizz partner integration manager. After modifying the podfile, run `pod install`. You will be prompted to enter a username. Enter any valid email address. Don't leave this value empty or the install will fail. When prompted for a password, enter the token repository provided by AdsWizz. Once authorization is successful, the dependency will be added and installed automatically to your project.

> **Note**
> You can safely use the same token you obtained for the **_AdswizzSDK_** installation. 

### Carthage
Visit the [Getting started](/iOS/SDKiOS/GetStarted#adding-the-sdk-to-your-xcode-project) section and follow the same steps for integrating **_AdswizzSDK_**.

### Manually
Drag and drop to copy the **_AdswizzSDKPinpointAnalytics.xcframework_** package into your application Frameworks group. Be sure to link and embed the **_AdswizzSDKPinpointAnalytics.xcframework_** binary.

## AdswizzSDKPinpointAnalytics integration
**_AdswizzSDKPinpointAnalytics_** doesn't need to be initialized. In order to pipe the Analytics events from **_AdswizzSDK_** to the AWS Pinpoint service, your application needs to create an **_AdswizzPinpointConnector_** object and add it to the **_AdswizzSDK_** list of connectors. 
To create an instance of **_AdswizzPinpointConnector_**, first you will create a configuration object.

### AdswizzPinpointConfiguration
The **_AdswizzPinpointConfiguration_** is used to instantiate the **_AdswizzPinpointConnector_**. The configuration requires the information listed below.

**Required**:
* region - the `region` to connect to the AWS Pinpoint service account
* projectId - the `projectId`  to connect to the AWS Pinpoint service account
* identityPoolId - the `identityPoolId`  to connect to the AWS Pinpoint service account

**Optional**:
* batchSize - the `batchSize` determines how many Analytics events will be send to the AWS Pinpoint service in one batch. The default value is 50
* minimumSendInterval - the `minimumSendInterval` indicates the minimum time interval between sending event batches to the AWS Pinpoint service. Measured in seconds. The default value is 30 seconds.

### AdswizzPinpointConnector
You are now ready to create the **_AdswizzPinpointConnector_**. Here is how you can do that in your application.

> Since **_AdswizzSDK_** `v8.0.0`, **_AdswizzPinpointConnector_** is `@MainActor` isolated and `AdswizzSDK.add(connector:)` is a main-actor call, so both must happen from a main-actor context — the `AppDelegate` below already is one. Note also that **_AnalyticsConnector_** is no longer exposed to Objective-C; if your app registers connectors from Objective-C, see the [v8.0.0 migration guide](iOS/SDKMigrations/v8_0_0.md#your-application-is-written-in-objective-c).

```swift
import AdswizzSDK
import AdswizzSDKPinpointAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
...
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do {
        let config = AdswizzPinpointConfiguration(region: <yourAWSTypeRegion>,
                                                projectId: <yourProjectId>,
                                                identityPoolId: <yourIdentityPoolId>,
                                                batchSize: <yourBatchSize>,
                                                minimumSendInterval: <yourMinimumSendInterval>)
        let pinpointConnector = try AdswizzPinpointConnector(with: config)
        AdswizzSDK.shared.add(connector: pinpointConnector)
    } catch {
        print(error)
    }

    //the configuration object is optional, unless you want to override the Info.plist values
    //or simply didn't add the string settings in your app's Info.plist
    let config = AdswizzSDKConfig(playerId: "yourPlayerId", installationId: "yourInstallationId", appStoreId: "yourAppAppleID")
    do {
        try AdswizzSDK.shared.initialize(with: config)
    } catch {
        print(error)
    }
    ...
}
```
And that's it! You have successfully added the AWS Pinpoint service to your **_AdswizzSDK_** integration in your application. **_AdswizzSDK_** will send the Analytics events it generates to the **_AdswizzPinpointConnector_** object. When it accumulates enough events (matching the `batchSize`), the **_AdswizzPinpointConnector_** will send them to the AWS Pinpoint service.

> **Note**
> By using Charles as proxy, you may notice that the API calls to the AWS Pinpoint service will return HTTP code 202 instead of 200. That is the expected behaviour. HTTP status code 202 means that the requests have been accepted for processing but the processing has not yet been completed (reported by the AWS servers).
