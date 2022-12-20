# Before you start

This guide is addressed to iOS Developers who want to integrate the **_AdswizzSDK_** in their iOS apps. You'll find a quick overview below, more details are provided for each scenario in their respective chapter.

## Thread safety

**IMPORTANT: The AdswizzSDK is NOT thread safe, so it is expected that all the calls to the SDK and any updates to the MediaPlayerState are done on the main thread. The AdswizzSDK does all the heavy lifting on background queues, so that the main queue remains responsive.**

## User privacy and permissions

The **_AdswizzSDK_** was carefully crafted with user privacy in mind. This also extends to iOS permissions. For that, we've built **_AdswizzSDKPrivacyData_**, a helper framework for the iOS **_AdswizzSDK_**, which has all the Privacy-Sensitive APIs that **_AdswizzSDK.framework_** requires. **_AdswizzSDKPrivacyData_** provides a way to exclude sensitive APIs that would otherwise force your app to add unwanted permissions usage description strings in the app's Info.plist.

For more information on **_AdswizzSDKPrivacyData_**, we strongly suggest that you consult [Get started](/SDKiOS/GetStarted) for how **_AdswizzSDKPrivacyData_** operates, as well as the [Permissions](/SDKiOS/GeneralSettings#permissions) chapter from the **_AdswizzSDK_** [Privacy](/SDKiOS/GeneralSettings#privacy) section.

### User privacy (AppTrackingTransparency)

Starting with iOS 14, Apple fundamentally changed the way the Identifier For Advertisers (IDFA) value can be accessed. Part of the App Tracking Transparency framework, the process implies a 2-steps approach:
STEP1) **The integrator (host app) is responsible** for setting up a NSUserTrackingUsageDescription to display a system-permission alert request, and then call requestTrackingAuthorization(completionHandler:) to present the app-tracking authorization request to the end user.
STEP2) Provided end users will grant permission for tracking, the AdswizzSDK will employ the new framework to read the IDFA value.

**N.B.: The AdswizzSDK will not show the request for permission dialogue, as the publisher is responsible for controlling and designing the user experience for obtaining the tracking consent. We encourage you to involve your product, UX/UI and engineering teams in the process of designing the best solution. It is very important that you ensure a high opt-in rate for the Tracking permission, as strong business value (higher CPMs) is dependent on being able to read the IDFA value.**

### How to prevent the SDK from accessing the iOS permissions

By default, The **_AdswizzSDK_** can access the iOS permissions for your app, by querying their statuses (granted, denied, etc.) using **_AdswizzSDKPrivacyData_** public API.
However, here is how your app can prevent the SDK from accessing the iOS permissions:
1. Instruct **_AdswizzSDKPrivacyData_** to exclude specific iOS permissions (or all of them) when you link your app against the **_AdswizzSDK_**. For more information on how to do that, consult the [Adding the SDK to your Xcode project](/SDKiOS/GetStarted#adding-the-sdk-to-your-xcode-project) chapter and the relevant section depending on how you decided to integrate **_AdswizzSDK_**.
2. Use the **_AdswizzSDK_** API to programmatically disable access to specific permissions (or all of them) at runtime after the **_AdswizzSDK_** is initialized. For more details please refer to the [Permissions](/SDKiOS/GeneralSettings#permissions) chapter from the [Privacy](/SDKiOS/GeneralSettings#privacy) section.

## What is ‘Client-Side Insertion’

For client-side scenarios you may use any streaming server and you are not required to use AIS (Ads Insertion Server). 
Your app is responsible for the built-in logic to decide when to start and end an ad break by fetching ads from the ad server and playing them with your apps's audio/video capabilities.
The SDK will handle all communication during ad fetching with the ad server while being in charge of displaying the companion banner and performing various event reporting (impressions & quartiles).

## What is ‘Server-Side Insertion’

For the server-side scenario, it is required to have AIS (Ads Insertion Server) as a streaming server, with the audio ads being automatically inserted on the server-side. The streaming server and the SDK split their responsibilities as follows:

**Streaming Server:**
*  detects ad breaks and inserts audio ads into the audio stream
*  updates metadata to make it possible for the SDK to synchronize the companion banner with the audio content and to detect interactive ads

**SDK:**
*  decorates the audio stream URL to increase the targetability of ads
*  detects all events associated with an ad break (start, stop, change of ad)
*  retrieves, displays, and synchronizes the companion banner with the audio content based on metadata
*  retrieves and processes interactivity information based on metadata

## What is ‘Podcasting‘

For podcasting scenario your app will be able to stream or download podcasts from an AIS (Ads Insertion Server) server with the audio ads being automatically inserted on the server-side. The podcasting server and the SDK split their responsibilities as follows:

**Podcasting Server:**
*  "stiches" ad breaks and inserts audio ads into the podcast creative audio file

**SDK:**
*  decorates podcast stream URL to increase targetability of ads
*  detects all events associated with an ad break (start, stop, change of ad)
*  retrieves, displays, synchronizes companion banner with the audio content based on metadata information
*  retrieves and process interactivity metadata information based on metadata information
*  processes metadata to make it possible for the SDK to synchronize companion banner with the audio content, to detect interactive ads and / or enable Remote Audio Data measurement

## Prerequisites for ‘Client-Side Insertion’

To implement ‘Client-Side Insertion’ successufully, you will need to set/provide the following information for your **_AdswizzAdRequest_** object within **_AdRequestConnection_**:
*  adServer = the name of the AdServer used to fetch ads from
*  zoneId = identifier of the zone used to retrieve audio/video ads from
*  companionZones = (optional) identifier of the zone from which to retrieve creatives to be displayed by the companion banner
*  (optional) list of custom site variables used for ads selection (e.g referrer)

The following can be set as general AdswizzSDK parameters:
*  (optional) GDPR consent value
*  (optional) CCPA (U.S. privacy string) consent value
*  (optional) location accuracy
*  (optional) location enable significant changes

## Prerequisites for ‘Server-Side Insertion’

To implement ‘Server-Side Insertion’ successufully, you will need to set/provide the following information for your **_AdswizzAdStreamManager_** object:
*  adServer = the name of the Adserver used to insert ads from
*  companionZones = (optional) identifier of the zone from which to retrieve creatives to be displayed by the companion banner
*  adStreamURL = URL of the audio stream (pass it to **_AdswizzAdStreamManager_**'s play() method)

The following can be set as general AdswizzSDK parameters:
*  (optional) GDPR consent value
*  (optional) CCPA (U.S. privacy string) consent value
*  (optional) location accuracy
*  (optional) location enable significant changes

## Prerequisites for ‘Podcasting’

For a successfully Podcasting integration, you will need to set/provide the following information for your **_AdswizzAdPodcastManager_** object:
*  adServer = the name of the Adserver used to play podcasts
*  companionZones = (optional) identifier of the zone from which to retrieve creatives to be displayed by the companion banner
*  adPodcastURL = URL of the audio stream (pass it to **_AdswizzAdPodcastManager_**'s _play()_ method)

The following can be set as general AdswizzSDK parameters:
*  (optional) GDPR consent value
*  (optional) CCPA (U.S. privacy string) consent value
*  (optional) location accuracy
*  (optional) location enable significant changes
