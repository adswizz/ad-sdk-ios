# AdswizzSDK Analytics

The **_AdswizzSDK_** framework collects and exposes information on SDK events that occur during its lifecycle. It was built to log various event types (informative and errors) that cover both integration robustness and ad lifecycle management in both client-side and server-side scenarios.
To help integrators complement their specific app analytics systems (e.g. Firebase, Mixpanel etc) with AdsWizz SDK internal events, the **_AdswizzSDK_** framework provides you with the ability to receive all the analytics events from the SDK and forward them to your own ingestion pipelines by implementing the **_AnalyticsConnector_** protocol. 
To learn more about the types of events you can listen and use, please reach out to your Integration Manager at AdsWizz.

AdsWizz may also use this mechanism to collect and analyze SDK performance metrics in order to identify integration-specific issues that may affect capacity or impressions/opportunities ratio.

```swift
class YourAnalyticsConnector: AnalyticsConnector {
  func log(_ event: AnalyticsEvent, _ timestamp: Date) {
      //Store or send this event to your desired platform
      //This will be called on a background queue    
  }

  func send(forced: Bool) {
      //Get's called when the SDK uninitialize. There might be other times in the future were this gets called.
      //If forced is true you should be flushing the stored events ASAP. If it is false you can send your events whenever you want.
      //This will be called on a background queue    
  }
}
```

Events whose level is set to **_error_** may be of particular interest.

## Customize AnalyticsEvent

In addition to being able to intercept and process Analytics events logged by AdswizzSDK through an **_AnalyticsConnector_** implementation, you can add your own attributes associated with all the **_AnalyticsEvent_** objects that are generated during the SDK's lifetime.
The AdswizzSDK is able to pass down your key-value collection of custom attributes/properties for all events generated from the moment it is initialized, through requesting ads and during ad playback.
The exposed **_AnalyticsCustomData_** interface encapsulates any additional data you wish to pass for every **_AnalyticsEvent_**. Here is an example of how you can do that:

```swift
class YourCustomAnalyticsData {
    private let internalParams: [String: String]?
    //these represent your custom key-value collection
    var params: [String : Any]? { //required by `AnalyticsCustomData` protocol
        return internalParams
    }
    
    init(params: [String: String]? = nil) {
        self.internalParams = params
    }
}

extension YourCustomAnalyticsData: AnalyticsCustomData {}

```

The params you provide into `YourCustomAnalyticsData` will be reflected in the **_customParams_** property of the **_AnalyticsEvent_** objects.
To inject `YourCustomAnalyticsData` created above, you need to pass it to the AdswizzSDK using one of the approaches detailed below.

### Custom analytics data through AdRequest

You can instruct the AdswizzSDK to track your custom analytics data by passing your object that implements **_AnalyticsCustomData_** to your **_AdRequest_** implementation or **_AdswizzAdRequest_** whichever you are using. Note that the AdswizzSDK will keep a strong reference for your object that implements **_AnalyticsCustomData_**.

Here is an example using a custom **_AdRequest_**:

```swift
class CustomAdRequest: AdRequest {
    override var url: URL? {
        return internalUrl
    }
    private let internalUrl: URL?
    init(with url: URL?, analyticsCustomData: AnalyticsCustomData? = nil) {
        internalUrl = url
        super.init(analyticsCustomData: analyticsCustomData)
    }
}

...

let url: URL = <your URL here>
let customData = YourCustomAnalyticsData(params: ["key": <value>])
let adRequest = CustomAdRequest(with: url, analyticsCustomData: customData)

do {
    let connection = try AdRequestConnection(for: adRequest)
    ...
} catch {
    print(error)
}
...

```

Here is an example using the **_AdswizzAdRequest_**:

```swift
var adRequest: AdswizzAdRequest!
let customData = YourCustomAnalyticsData(params: ["key": <value>])
do {
      adRequest = try AdswizzAdRequest.Builder()
              .with(server: "SERVER_PROVIDED_BY_PIM")
              .with(zone: <zone>)
              .with(analyticsCustomData: customData)
              .build()
} catch {
     print(error)
}
...

do {
    let connection = try AdRequestConnection(for: adRequest)
    ...
} catch {
    print(error)
}
...

```

### Custom analytics data through Ad Manager

Another approach to passing `YourCustomAnalyticsData` is by using the **_analyticsCustomData_** property of the **_AdManager_** instance. Here you can update either the entire reference of the `YourCustomAnalyticsData` or alter only the `params` property. The AdswizzSDK will use the (updated) `params` to populate `customParams` property of any subsequent **_AnalyticsEvent_** triggered after your update.

```swift
var adManager: AdManager!
let customData = YourCustomAnalyticsData(params: ["key": <value>])
...

adManager.analyticsCustomData = customData
...

```
