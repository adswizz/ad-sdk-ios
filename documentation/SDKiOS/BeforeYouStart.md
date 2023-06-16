# Before you start

This guide is addressed to iOS Developers who want to integrate the **_AdswizzSDK_** in their iOS apps. You'll find a quick overview below, more details are provided for each scenario in their respective chapter.

## Thread safety

**IMPORTANT: The AdswizzSDK is NOT thread safe, so it is expected that all the calls to the SDK and any updates to the MediaPlayerState are done on the main thread. The AdswizzSDK does all the heavy lifting on background queues, so that the main queue remains responsive.**

## User privacy and permissions

The **_AdswizzSDK_** was carefully crafted with user privacy in mind. This also extends to iOS permissions. For that, we've built **_AdswizzSDKPrivacyData_**, a helper framework for the iOS **_AdswizzSDK_**, which has all the Privacy-Sensitive APIs that **_AdswizzSDK.framework_** requires. **_AdswizzSDKPrivacyData_** provides a way to exclude sensitive APIs that would otherwise force your app to add unwanted permissions usage description strings in the app's Info.plist.

For more information on **_AdswizzSDKPrivacyData_**, we strongly suggest that you consult [Get started](/iOS/SDKiOS/GetStarted) for how **_AdswizzSDKPrivacyData_** operates, as well as the [Permissions](/iOS/SDKiOS/GeneralSettings#permissions) chapter from the **_AdswizzSDK_** [Privacy](/iOS/SDKiOS/GeneralSettings#privacy) section.

### User privacy (AppTrackingTransparency)

Starting with iOS 14, Apple fundamentally changed the way the Identifier For Advertisers (IDFA) value can be accessed. Part of the App Tracking Transparency framework, the process implies a 2-steps approach:
STEP1) **The integrator (host app) is responsible** for setting up a NSUserTrackingUsageDescription to display a system-permission alert request, and then call requestTrackingAuthorization(completionHandler:) to present the app-tracking authorization request to the end user.
STEP2) Provided end users will grant permission for tracking, the AdswizzSDK will employ the new framework to read the IDFA value.

**N.B.: The AdswizzSDK will not show the request for permission dialogue, as the publisher is responsible for controlling and designing the user experience for obtaining the tracking consent. We encourage you to involve your product, UX/UI and engineering teams in the process of designing the best solution. It is very important that you ensure a high opt-in rate for the Tracking permission, as strong business value (higher CPMs) is dependent on being able to read the IDFA value.**

### How to prevent the SDK from accessing the iOS permissions

By default, The **_AdswizzSDK_** can access the iOS permissions for your app, by querying their statuses (granted, denied, etc.) using **_AdswizzSDKPrivacyData_** public API.
However, here is how your app can prevent the SDK from accessing the iOS permissions:
1. Instruct **_AdswizzSDKPrivacyData_** to exclude specific iOS permissions (or all of them) when you link your app against the **_AdswizzSDK_**. For more information on how to do that, consult the [Adding the SDK to your Xcode project](/iOS/SDKiOS/GetStarted#adding-the-sdk-to-your-xcode-project) chapter and the relevant section depending on how you decided to integrate **_AdswizzSDK_**.
2. Use the **_AdswizzSDK_** API to programmatically disable access to specific permissions (or all of them) at runtime after the **_AdswizzSDK_** is initialized. For more details please refer to the [Permissions](/iOS/SDKiOS/GeneralSettings#permissions) chapter from the [Privacy](/iOS/SDKiOS/GeneralSettings#privacy) section.

