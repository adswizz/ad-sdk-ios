# Prepare your application for advanced targetability capabilities

## Handle data collection

The AdswizzSDK framework can provide several types of device information using a data collector module. You can choose to control data collection by toggling the **_disableDataCollection_** property on the **_AdswizzSDK_** shared instance. The default is `false`.
As best practice, your app should get the user's opt-in or opt-out and instruct the **_AdswizzSDK_** to collect data or not, based on user's preference.
Ideally, you should sync data collection consent with the GDPR/CCPA consent if it applies. e.g: if the user has declined their GDPR consent, you should also set **_disableDataCollection_** to `true`.

## Privacy implications

Please be advised that, if you choose to enable Raw Data Signal Collection, you will have to inform your customers that your application handles and processes anonymized personal data. <br>
**We highly encourage you to loop your product and legal teams in the process of defining the best way to reflect this in your application’s Privacy Policy.**

---------------------------------------------------------------------------------------------------------------------------------------------------
| Data collected for <br>**_Device Targeting_** | Data collected for <br>**_Contextual Targeting_** | Data collected for <br>**_User Targeting_**|
|:-----------------|:---------------------|:--------------|
| * device name and locale <br>* device type <br>* screen brightness level<br>* audio volume level<br>* battery level and status (charging/not charging)<br>* bundle ID<br>* operating system version and name | * Bluetooth devices (currently connected and history)<br>* Wi-Fi Status (true/false) and WiFi network name / SSID (if connected)<br>* network carrier name and country<br>* accelerometer, GPS and gyroscope data<br>* headphone jack status (plugged/unplugged)<br>* time zone information (in GMT format)<br>* daylight saving time status (true/false) | * IDFA (IdentifierForAdvertising) status (enabled/disabled) and ID (if enabled) |


## Technical prerequisites

Since iOS 13, Wi-Fi data can only be retrieved if the app entitlements contains the `Access Wi-Fi Information` capability.
In order to set it, go to your app's target, select Signing & Capabilities, and add the `Access Wi-Fi Information` capability by tapping the "+" button above.
