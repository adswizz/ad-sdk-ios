# AdswizzSDK general settings

## Companion banner

### Extra exposure time for an AdCompanionView

By default, the **_AdCompanionView_** will stop displaying the content after the ad finishes playing. If you need to keep the companion on the screen for a longer period of time (or indefinitely), you can configure it like this.


> All the snippets below configure `AdswizzSDK.shared`, which is `@MainActor` isolated since `v8.0.0` — call them from a main-actor context such as your `AppDelegate` or a `@MainActor` type. See the [v8.0.0 migration guide](iOS/SDKMigrations/v8_0_0.md).

```swift
let adCompanionOptions = AdCompanionOptions()
adCompanionOptions.extraExposureTime = 1.2 // these are seconds.
// if you need the companion forever on the screen
// adCompanionOptions.extraExposureTime = .greatestFiniteMagnitude
AdswizzSDK.setAdCompanionOptions(adCompanionOptions)
```

### Preferred resource type

You can instruct the **_AdswizzSDK_** to select and load a particular resource type for the **_AdCompanionView_** instance(s) by setting the `preferredResourceType` property for your **_AdCompanionOptions_** config. You can set one of the following:
* html - will select and load the first valid HTML resource
* iFrame - will select and load the first valid iFrame resource
* image - will select and load the first valid static image resource

By default, the **_AdswizzSDK_** selects the first available resource while querying the `Companion` associated data. Additionally, when no resource is found that matches the preferred type, it defaults to the first found valid resource.

```swift
let adCompanionOptions = AdCompanionOptions()
adCompanionOptions.preferredResourceType = .html // favor html resources
AdswizzSDK.setAdCompanionOptions(adCompanionOptions)
```

## Location

By default, the **_AdswizzSDK_** will attempt to collect location updates using _startUpdatingLocation API_ from _CLLocationManager_ if the following conditions are met:
* ZeroConfig `location` setting is enabled. Note that this setting is enabled by default. To disable this setting in your app's AdswizzSDK ZeroConfig instance, contact your AdsWizz partner integration manager.
* location permission is granted by your app

You can also prevent the **_AdswizzSDK_** from collecting location updates by setting **_false_** for the `.location` permission type status via the `setPermissionStatus(for type: PermissionType, status: Bool)` method in the AdswizzSDK shared instance. See [Disable permissions programmatically](/iOS/SDKiOS/GeneralSettings#disable-permissions-programmatically) in the [Privacy](/iOS/SDKiOS/GeneralSettings#privacy) section below.

### Enable significant changes for location

By default, this option is set to **_false_**. If you prefer to limit the location updates to significant changes, set this property to **_true_**.

```swift
AdswizzSDK.shared.enableLocationSignificantChanges = true
```

### Location accuracy
By default, the **_AdswizzSDK_** location accuracy is set to the nearest kilometer. You can update this to a new _CLLocationAccuracy_ value.

```swift
AdswizzSDK.shared.locationAccuracy = kCLLocationAccuracyBest
```

## Privacy

### GDPR

AdsWizz services are GDPR compliant. As a result, the **_AdswizzSDK_** will decorate URLs that connect to AdsWizz services accordingly, to reflect the desired GDPR user consent. To modify the GDPR consent you need to configure it like this:

```swift
AdswizzSDK.shared.gdprConsent = <Desired_GDPR_Consent>
```

If not configured, the default value for GDPR consent in the **_AdswizzSDK_** will be  **_notApplicable_**. Other possible values are:
  * **_notAsked_**: the user has not been asked about GDPR consent yet
  * **_granted_**: the user has granted access
  * **_denied_**: the user has denied access

### CCPA

With the introduction of CCPA in the US, the **_AdswizzSDK_** gives you the possibility to forward the user consent accordingly.

```swift
AdswizzSDK.shared.ccpaConfig = AdswizzCCPAConfig.Builder()
                                                  .with(explicitNotice: <Desired_CCPA_Consent>)
                                                  .with(optOut: <Desired_CCPA_Consent>)
                                                  .with(lspa: <Desired_CCPA_Consent>)
                                                  .build()

```

The default value for **_explicitNotice_**, **_optOut_** and **_lspa_** is **_notApplicable_**. Other possibile values are **_yes_** and **_no_**.

### GPP

With the introduction of GPP standard from IAB, **_AdswizzSDK_** gives you the possibility to forward the gpp consent string accordingly.

```swift
AdswizzSDK.shared.gppConsent = "My GPP Consent String"

```

The default value for **gppConsent** is nil, which means this parameter won't be used by **_AdswizzSDK_**. The usage of the GPP consent string is similar to the TCF V2 consent string.

### GPC

**_AdswizzSDK_** is GPC compliant (Global Privacy Control). As a result, the **_AdswizzSDK_** will decorate URLs that connect to Adswizz services accordingly, to reflect the desired GPC consent. To modify the GPC consent, you need to configure it like this:

```swift
AdswizzSDK.shared.consent.gpc = true //or false

```

Default value for the **gpc** consent is `false`.

## Permissions

The **_AdswizzSDKPrivacyData_** public source framework, which is delivered with the **_AdswizzSDK_** binaries, allows your app to request permissions in a unified and transparent manner. Your app can still request permissions without using the interface exposed by the **_AdswizzSDKPrivacyData_** framework. However, with transparency in mind, the **_AdswizzSDK_** uses **_AdswizzSDKPrivacyData_** to read the status for all permissions your app allows to use.

Additionally, the **_AdswizzSDK_** provides a programmatic way for your app to control which permissions the SDK can use to query status.

#### Get status

To get the current permission status in the SDK, use the **_AdswizzSDK_**'s shared instance method called `permissionStatus(for type: PermissionType) -> Bool`. `permissionType` is described in the **_AdswizzSDKPrivacyData_** framework. This method returns `true` if the **_AdswizzSDK_** can use the API guarded by the permission, or `false` otherwise.

```swift

//Example on how to read the status of a permission type as described in AdswizzSDKPrivacyData.
//By default, `permissionStatus(for type: PermissionType)` method will return `true` for any permission type.
let status = AdswizzSDK.shared.permissionStatus(for: .location)
print(status)

```

#### Disable permissions programmatically

You can instruct the **_AdswizzSDK_** whether it can use the data exposed by any permission type described in the **_AdswizzSDKPrivacyData_** framework by calling the `setPermissionStatus(for type: PermissionType, status: Bool)` method. Pass `true` for the status parameter if **_AdswizzSDK_** is allowed to use the permission or false if the **_AdswizzSDK_** is denied access.

By default the **_AdswizzSDK_** will use the API unlocked by each permission but you can limit the **_AdswizzSDK_** usage dynamically by setting the appropriate status.
The **_AdswizzSDK_** will ensure that if the permission status is set to false, the API guarded by the permission is not used, thus giving you granular control of what sensitive data the **_AdswizzSDK_** will use during it's lifetime.

Here is what happens when you set a permission status to `false`:
* **_location_**: the SDK will not continue to process `CLLocationManager` updates.
* **_locationAdvanced_**: same as location. You can set which one you like.
* **_photo_**: the SDK will not save any photos as resulting from an interactive ad with the "download photo" action.
* **_microphone_**: the SDK will not start recording the user during an interactive voice ad. If this is set, interactive voice ad will not happen.
* **_speech_**: the SDK will not use the speech transcriber during an interactive voice ad. If this is set, interactive voice ads will be disabled.
* **_calendar_**: the SDK will not insert any events in the user's calendar during an interactive ad with the "add to calendar" action.
* **_camera_**: For future use. Currently, the SDK doesn't use any data from the camera.
* **_contacts_**: For future use. Currently the SDK doesn't access the contacts.
* **_idfa_**: Since iOS 14, the app needs to request permission from the user to track. If set to `false`, the SDK will not use the IDFA (Identifier for Advertisers) from the system.
* **_motionActivity_**: the SDK will not use any updates from `CMMotionActivityManager`.

```swift

//Example on how to set the status of a permission type as described in AdswizzSDKPrivacyData.
AdswizzSDK.shared.setPermissionStatus(for: .location, status: false)

//Now `permissionStatus(for type: PermissionType)` method will return `false` for the `location` permission type.
let status = AdswizzSDK.shared.permissionStatus(for: .location)
print(status) //prints false

```

Here is how you can prevent access for **_AdswizzSDK_** to all permissions:

```swift
import AdswizzSDK
import AdswizzSDKPrivacyData

...

PermissionType.all.forEach {
    AdswizzSDK.shared.setPermissionStatus(for: $0, status: false)
}

```

## Podcasts

### Enable background downloads

By default,the  **_AdswizzSDK_** uses a background `URLSession` configuration to be able to perform podcast downloads even when your app is put in the background.
In this case the download is performed in another process. When the download finishes, the system resumes the app and calls the `UIApplicationDelegate` method `application(_:handleEventsForBackgroundURLSession:completionHandler:)`.

This delegate method receives a completion handler as its final parameter. Just pass it to the `AdswizzSDK` shared instance property called `backgroundSessionCompletionHandler`. Here's an example:

```swift
func application(_: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        AdswizzSDK.shared.backgroundSessionCompletionHandler = completionHandler
}
```

### Enable RAD

You can enable or disable Remote Audio Data measurement for your podcasts based on user consent. It can be configured like this:

```swift
AdswizzSDK.shared.disableRAD = false //or `true` if user opted out
```
