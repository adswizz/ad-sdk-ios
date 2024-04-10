# Privacy manifest
 
Since WWDC 2023, Apple brought a vast collection of user privacy improvements. Here are the main components of what Apple announced with regards to privacy changes and which they will apply starting in Spring 2024.

1. **Privacy Manifests**. Standardized files that outline the privacy practices of an app or third-party framework (SDK). 
2. **Privacy Report**. An auto-generated reference doc, based on the details contained in all relevant Privacy Manifest files, designed to make it easier to fill out the Privacy Nutrition Label questionnaire during App Store submission.
3. **SDK Signing**. A way for app developers to be confident that the third-party SDKs they use (such as **_AdswizzSDK_**) are the original, validated versions and have not been tampered with.
4. **Required Reason APIs**. A limited selection of iOS functionality that could potentially be used for fingerprinting, for which an “allowed reason” for usage must be declared in the Privacy Manifest file. (Note that “API” in this context means things like accessing disk space, not service APIs the way we typically think of them in the world of mobile marketing).
5. **Tracking Domains**. Internet domains that an app or SDK connects to that engage in “tracking.” These must be declared in the Privacy Manifest file, and network requests to these domains will fail until the user gives ATT consent.

## Decoding the Privacy Manifest

The *Privacy Manifest* file is a centralized place to set privacy-related configuration items. An app can have one, and SDKs can also each have their own.
There are four sub-sections in a Privacy Manifest file:

* **NSPrivacyTracking**. This is a Boolean that indicates whether an app or third-party SDK uses data for “tracking,” as defined under the ATT framework. See the [User privacy and data use](https://developer.apple.com/app-store/user-privacy-and-data-use/) for more details.
* **NSPrivacyTrackingDomains**. An array of strings that lists the internet domains an app or third-party SDK connects to that engage in “tracking”. If the user has not granted tracking permission through the ATT framework, network requests to these domains fail.
* **NSPrivacyCollectedDataTypes**. An array of dictionaries that describes the data types an app or third-party SDK collects. Xcode will use these values to generate a report for easy reference when answering the Privacy Nutrition Labels questionnaire on App Store Connect (see the [Data Usage](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests) docs).
* **NSPrivacyAccessedAPITypes**. An array of dictionaries that describe the iOS APIs an app or third-party SDK accesses that have been designated as APIs that require reasons to access (see the [Required reason API](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api) docs).

## Privacy manifest for AdswizzSDK

As of `v7.9.0`, **_AdswizzSDK_**, as a third-party framework, provides its own privacy manifest (PrivacyInfo.xcprivacy file) and adheres to Apple's Privacy guidelines for all the relevant sub-sections above. Here is the list of **_AdswizzSDK_** binary frameworks that fall under the Privacy guidelines, thus each being shipped with its own privacy manifest file:
* **AdswizzSDK**. The main xcframework for the Adswizz ad insertion solution.
* **AdswizzWatchSDK**. A companion xcframework for **AdswizzSDK**, which provides Apple Watch support (for interactive ads such as ShakeMe™ or Voice Ads).
* **AdswizzSDKPinpointAnalytics**. A standalone xcframework which provides an AWSPinpoint wrapper for the **AdswizzAnalyticsConnector** interface.

The following components do not require a privacy manifest:
* **AdswizzSDKCore**. A helper xcframework (automatically installed with **_AdswizzSDK_** via the Cocoapods integration).
* **AdswizzSDKPrivacyData**. Source based project to help with various permission requests.

> The information on this page is based on learnings from Apple’s public WWDC developer session videos, updated iOS documentation pages, and follow-up Q&A sessions with the Apple Privacy Engineering team.
