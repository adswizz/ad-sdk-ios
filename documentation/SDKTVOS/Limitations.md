# AdswizzSDK tvOS limitations

The **_AdswizzSDK_** tvOS framework comes with several limitations due to the unavailability or partial support of specific iOS frameworks and features on the tvOS platform. These limitations have led to adjustments in functionality for tvOS, detailed below:

## AdCompanionView

Features reliant on web content, such as **_AdCompanionView_** with HTML content and in-app notifications with web elements, are not supported on tvOS. These features have been removed for the tvOS platform.

> Note that although the **_AdCompanionView_** cannot render HTML content on the tvOS platform, the support for static resources such as images has been introduced in AdswizzSDK `v7.12.0`.

## Interactive Ads

Interactive ad features, including calendar actions, saving photos, email actions, motion-based features, and local notifications, are unavailable on tvOS due to platform limitations.

## AdswizzSDK Pinpoint Analytics

The **_AdswizzSDKPinpointAnalytics_** module is not available on tvOS due to the lack of tvOS support for the AWSCore framework.

## Watch Connectivity

Features that rely on communication with watchOS, such as Watch Companion App interactions, are not included in the tvOS framework.

In summary, while the core functionality of **_AdswizzSDK_** on tvOS remains intact, certain advanced or interactive features have been adjusted or removed to ensure compatibility with the platform. These limitations are designed to align the SDK’s functionality with the capabilities of tvOS while maintaining a seamless user experience.

--- 

## AdswizzSDK Privacy Data Kit

The **_AdswizzSDKPrivacyDataKit_** module, which manages privacy-related permissions and data collection, has limited functionality on tvOS due to platform constraints. As a result, certain modules within the **_AdswizzSDKPrivacyDataKit_** are not supported on tvOS. These adjustments ensure compliance with tvOS capabilities while maintaining the SDK’s core functionalities.

### AdswizzSDKPrivacyDataCalendar

The **_AdswizzSDKPrivacyDataCalendar_** module is not available on tvOS, as the platform does not provide access to calendar data.

### AdswizzSDKPrivacyDataContacts

The **_AdswizzSDKPrivacyDataContacts_** module is not available on tvOS, as the platform does not provide access to contact data.

### AdswizzSDKPrivacyDataMotion

The **_AdswizzSDKPrivacyDataMotion_** module is not available on tvOS, as the platform does not provide access to motion capabilities.

### AdswizzSDKPrivacyDataSpeech

The **_AdswizzSDKPrivacyDataMotion_** module is not available on tvOS, as the platform does not provide access to speech capabilities.
