# Integrating AdswizzSDKPrivacyDataKit components

## Requirements
* Xcode 15.2+
* iOS 12.0+
* Swift 5.9.2+

## Dependencies
Note that the **_AdswizzSDKPrivacyDataCore.xcframework_** is built as a standalone binary framework, it compiles out-of-the-box and does not require any extra dependency.
However, all the other [components](/iOS/SDKPrivacyDataKit/AdswizzSDKPrivacyDataKit#structure) that handle a specific permission, each depends on the **_AdswizzSDKPrivacyDataCore_** module.<br>
The **_AdswizzSDKPrivacyDataCore_** dependency above is automatically added if you choose to integrate any component from the **_AdswizzSDKPrivacyDataKit_** using Cocoapods or Swift Package Manager. If you choose either the Carthage or the manual integration, you will have to provide it at link time.<br>

**_AdswizzSDKPrivacyDataCore_** is delivered as source code but the integration relies on the .xcframework to maintain binary compatibility with AdswizzSDK. The rest of the components are delivered as source code available from the Github official repository for AdswizzSDK. See next how to add **_AdswizzSDKPrivacyDataKit_** components to your Xcode project.

## Installation

To integrate components from **_AdswizzSDKPrivacyDataKit_** for iOS into your own project, you can use the same approach as for **_AdswizzSDK_**, by using one of the following methods:
- [Swift Package Manager](#swift-package-manager)
- [CocoaPods](#cocoapods)
- [Carthage](#carthage)
- [Manually](#manually)

> You should use one and only one of these methods to install any components under the **_AdswizzSDKPrivacyDataKit_** suite.
> Adding any component in multiple ways, loads duplicate copies of the module into the project and causes compiler/linker errors.

### Swift Package Manager

Adding the desired **_AdswizzSDKPrivacyDataKit_** Swift package components into your project can be done directly in Xcode in a few simple steps, same as for the [AdswizzSDK](/iOS/SDKiOS/GetStarted#swift-package-manager) product:

1. Go to Files > Swift Packages > Add Package Dependency… and include the URL of the GitHub repository:

```ruby
https://ADSWIZZ_TOKEN@github.com/adswizz/ad-sdk-ios
```
> Replace ADSWIZZ_TOKEN with the Personal Access Token received from your Technical Account Manager.

2. Next, you'll see the repository rules for which version of the AdswizzSDK you want Swift Package Manager to install. Choose the `Up to Next Major Version` as it will use the latest compatible version of the dependency that can be detected from the main branch. Select which project you want Swift Package Manager to add the AdswizzSDK, then click "Add Package".

3. Wait for Xcode to finish downloading and resolving the Swift package into your project.
4. Now you can choose the package products and targets. Assuming that you have already added the **AdswizzSDK** product to your project, the other products are optional and you can opt-in and select the ones matching the permissions your app is using. For example, if your app asks for the tracking system permission, you should select the **AdswizzSDKPrivacyDataIDFA** product and link it to your project's target. This enables **_AdswizzSDK_** to access the ATT framework and use the IDFA identifier for advanced listening context and better targeting.

Another example, if you plan to leverage AdsWizz's interactive audio ad formats, _AdswizzSDK_ will need access to the microphone and speech permissions so you should also include the **AdswizzSDKPrivacyDataMicrophone** and **AdswizzSDKPrivacyDataSpeech** products into your project's target.

### Cocoapods
The recommended version for Cocoapods is 1.15.0 or later. If you already have a Podfile, for each of the [components](/iOS/SDKPrivacyDataKit/AdswizzSDKPrivacyDataKit#structure) you wish to install, just add the following line in your application target:

* **IDFA**         - `pod 'AdswizzSDKPrivacyDataKit/IDFA', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git"`
* **Photos**       - `pod 'AdswizzSDKPrivacyDataKit/Photos', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git"`
* **Microphone**   - `pod 'AdswizzSDKPrivacyDataKit/Microphone', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git"`
* **Speech**       - `pod 'AdswizzSDKPrivacyDataKit/Speech', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git"`
* **Location**     - `pod 'AdswizzSDKPrivacyDataKit/Location', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git"`
* **Calendar**     - `pod 'AdswizzSDKPrivacyDataKit/Calendar', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git"`
* **Motion**       - `pod 'AdswizzSDKPrivacyDataKit/Motion', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git"`
* **Contacts**     - `pod 'AdswizzSDKPrivacyDataKit/Contacts', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git"`
* **Camera**       - `pod 'AdswizzSDKPrivacyDataKit/Camera', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git"`

Replace **_ADSWIZZ_GITHUB_TOKEN_** with the token you received from AdsWizz. You can obtain a token from your AdsWizz partner integration manager. After modifying the podfile, run `pod install`. You will be prompted to enter a username. Enter any valid email address. Don't leave this value empty or the install will fail. When prompted for a password, enter the token repository provided by AdsWizz. Once authorization is successful, the dependency will be added and installed automatically to your project.

> **Note**
> You can safely use the same token you obtained for the **_AdswizzSDK_** installation. 

### Carthage
Visit the [Carthage](/iOS/SDKiOS/GetStarted#carthage) section and follow the same steps for integrating **_AdswizzSDK_**. Be sure to link and embed the **_AdswizzSDKPrivacyDataCore.xcframework_** binary and the other dependent binaries your application needs from the same `Build` folder generated by Carthage.

### Manually
Drag and drop to copy the **_AdswizzSDKPrivacyDataCore.xcframework_** package into your application Frameworks group. Be sure to link and embed the **_AdswizzSDKPrivacyDataCore.xcframework_** binary. Now you can choose which other [components](/iOS/SDKPrivacyDataKit/AdswizzSDKPrivacyDataKit#structure) you need to link to your application target by dragging them into your app .workspace.


## Usage

**AdswizzSDKPrivacyDataCore** is the main standalone module (the 'Core') that the other components depend on and this allows your app to opt-in and instruct **_AdswizzSDK_** which permissions is able to use.
For the following modules, each refers to a specific system permission with its associated usage description key in your app's Info.plist:
* **AdswizzSDKPrivacyDataCalendar**: _NSCalendarsWriteOnlyAccessUsageDescription_ (iOS 17 only) / _NSCalendarsUsageDescription_ or _NSCalendarsFullAccessUsageDescription_
* **AdswizzSDKPrivacyDataCamera**: _NSCameraUsageDescription_
* **AdswizzSDKPrivacyDataContacts**: _NSContactsUsageDescription_
* **AdswizzSDKPrivacyDataIDFA**: _NSUserTrackingUsageDescription_
* **AdswizzSDKPrivacyDataLocation**: _NSLocationWhenInUseUsageDescription_ or _NSLocationAlwaysUsageDescription_
* **AdswizzSDKPrivacyDataMicrophone**: _NSMicrophoneUsageDescription_
* **AdswizzSDKPrivacyDataSpeech**: _NSSpeechRecognitionUsageDescription_
* **AdswizzSDKPrivacyDataMotion**: _NSMotionUsageDescription_
* **AdswizzSDKPrivacyDataPhotos**: _NSPhotoLibraryUsageDescription_

> **Important**: Only add the modules that match the permissions your app is actually using to avoid issues with AppStore Connect review on submission.

Although you are not required to, you can certainly leverage the public API exposed by the **AdswizzSDKPrivacyDataCore** module either by requesting a permission:
```swift
import AdswizzSDKPrivacyDataCore

AdswizzSDKPrivacyData.shared.request(permission: .idfa) { result in
  switch result.result {
  case let .success(value):
    //success
    print("Success! value = \(value.stringRepresentation)")
  case let .failure(error):
    //failure
    print("Something went wrong... error = \(error)")
  }
}
```
or just by querying the value of a certain permission type:
```swift
import AdswizzSDKPrivacyDataCore

let trackingValue = AdswizzSDKPrivacyData.shared.authorizationStatus(for: .idfa)
print("Tracking permission value = \(trackingValue.stringRepresentation)")
```
