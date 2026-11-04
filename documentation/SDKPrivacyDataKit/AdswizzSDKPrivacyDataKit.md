# AdswizzSDK PrivacyData Kit

Moving further with the release of **_AdswizzSDK_** [v7.10.0](/iOS/CHANGELOG#_7100-2024-10-25) and beyond, we're introducing an optional component suite called **AdswizzSDKPrivacyDataKit** which replaces the old mandatory dependency named **_AdswizzPrivacyData.framework_**. It is designed to act as an optional dependency for **_AdswizzSDK_** and easy to install with your favourite dependency integration manager.

## What is AdswizzSDKPrivacyDataKit?
**_AdswizzSDKPrivacyDataKit_** is an optional suite of frameworks for **_AdswizzSDK_** on iOS, that has all the Privacy-Sensitive API required by certain features bundled within the **AdswizzSDK.xcframework**. **_AdswizzSDKPrivacyData_**'s purpose is to facilitate the interoperability with **AdswizzSDK** and to allow your app to manage sensitive APIs (such as permission APIs) without adding unwanted permission usage decription strings in the app's `Info.plist` manifest. 
It is a transparent way to communicate to **AdswizzSDK** all your app-specific Privacy needs and constraints.

> Note that this version of **_AdswizzSDKPrivacyData_** is only compatible starting with **_AdswizzSDK_** version `v7.10.0`. If you are planning to integrate an older **_AdswizzSDK_** version, please use the default AdswizzSDKPrivacyData implementation available [here](https://github.com/adswizz/ad-sdk-ios-privacydata) and follow the instructions for AdswizzSDK pre-7.10.0 versions.

## How does it work?
**_AdswizzSDKPrivacyDataKit_** is meant to allow your application to control and decide which system permissions can **_AdswizzSDK_** use and query for statuses. This is accomplished by having multiple modules, each handling a specific permission while the "core" component is decoupled and is able to load those that are using the same protocols and interfaces publicly exposed.

Furthermore, from a technical standpoint, the **_AdswizzSDKPrivacyDataCore_** component is a standalone module that was built independently from **_AdswizzSDK_**. By taking advantage of Objective-C's superior runtime capabilities, **_AdswizzSDK_** only loads and uses the **_AdswizzSDKPrivacyData_** functionality if the **_AdswizzSDKPrivacyDataCore_** is installed.

## Advanced listening context
**_AdswizzSDKPrivacyDataKit_** enhances **_AdswizzSDK_** advanced targeting capabilities to supply personalised ads to your audience.<br>
It is important to note that this can only be achieved if you install the **_AdswizzSDKPrivacyDataIDFA_** component to allow **_AdswizzSDK_** to use the IDFA (Identifier for Advertisers) supplied by Apple's ATT framework.

## Structure

**_AdswizzSDKPrivacyDataKit_** includes the following components as frameworks:
* **AdswizzSDKPrivacyDataCore** 		- the core component that defines the public interfaces and symbols used by the other optional components below
* **AdswizzSDKPrivacyDataIDFA** 		- handles the tracking permission as defined by Apple's ATT framework
* **AdswizzSDKPrivacyDataPhotos** 		- handles the photos permission
* **AdswizzSDKPrivacyDataMicrophone** 	- handles the microphone permission
* **AdswizzSDKPrivacyDataSpeech** 		- handles the speech recognizer permission
* **AdswizzSDKPrivacyDataLocation** 	- handles the location permissions
* **AdswizzSDKPrivacyDataCalendar** 	- handles the calendar permissions
* **AdswizzSDKPrivacyDataMotion** 		- handles the motion activity permission
* **AdswizzSDKPrivacyDataCamera** 		- handles the camera permission (currently not used)
* **AdswizzSDKPrivacyDataContacts** 	- handles the contacts permission (currently not used)

For more details on how to integrate any of the above components from **_AdswizzSDKPrivacyDataKit_**, please visit the [Integrating AdswizzSDKPrivacyDataKit](/iOS/SDKPrivacyDataKit/IntegratingAdswizzSDKPrivacyDataKit) section.



