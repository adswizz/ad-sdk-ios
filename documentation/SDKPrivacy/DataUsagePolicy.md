# Data usage policy

Apple requires app developers to provide the data usage policy of the app when they submit their app to the App Store. See Apple's [User privacy and data use](https://developer.apple.com/app-store/user-privacy-and-data-use/) for more details. 
**_AdswizzSDK_** is used to interact with Adswizz services under the developer’s ownership and management. The framework cannot predict the usage of its APIs and features. Therefore, app developers should provide the privacy manifest that accurately reflects the data collected by the app. Below are the different categories identified by Apple and the corresponding data type used by the **_AdswizzSDK_** library suite.

## Collected Data

### Identifiers

<table style="width:100%">
<thead>
  <tr>
    <th style="width:35%">Data type</th>
    <th style="width:35%">AdswizzSDK library</th>
    <th style="width:20%">Purpose</th>
    <th style="width:10%">Linked to<br>Identity</th>
    <th style="width:7%">Tracking</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td><b>Device ID</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>✅</td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>✅</td>
  </tr>
</tbody>
</table>

### Other Data

<table style="width:100%">
<thead>
  <tr>
    <th style="width:35%">Data type</th>
    <th style="width:35%">AdswizzSDK library</th>
    <th style="width:20%">Purpose</th>
    <th style="width:10%">Linked to<br>Identity</th>
    <th style="width:7%">Tracking</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td><b>App Version</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>App Title</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>App Bundle</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>SDK version</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Platform Manufacturer</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Device Model</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzWatchSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Device Version</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzWatchSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Locale Info</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Timezone</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Platform</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Platform Version</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>identifierForVendor</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Battery (level)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Battery (state)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>WiFi SSID</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Carrier (name)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Carrier (country)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Device Volume</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Device Bluetooth</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Device Brightness</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Device idiom</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
</tbody>
</table>

### Other Data collected under specific conditions

`AdswizzSDK` and `AdswizzSDKPinpointAnalytics` frameworks can collect additional data if the conditions are met:
* Additional permissions are granted such as Motion Activity or Location
* The `DataCollector` (Listening Context) feature is enabled via ZeroConfig and programmatically if needed. For more info, please Contact your Adswizz Technical Account

<table style="width:100%">
<thead>
  <tr>
    <th style="width:35%">Data type</th>
    <th style="width:35%">AdswizzSDK library</th>
    <th style="width:20%">Purpose</th>
    <th style="width:10%">Linked to<br>Identity</th>
    <th style="width:7%">Tracking</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td><b>Location (latitude)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Location (longitude)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Location (altitude)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Location (speed)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Location (accuracy)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Location (PostalCode)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Location (City)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Location (Region)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Location (Country)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDKPinpointAnalytics</td>
    <td>Analytics</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Motion (rotation)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Motion (acceleration)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
  <tr>
    <td><b>Motion (confidence)</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td></td>
    <td>AdswizzSDK</td>
    <td>Third-Party Advertising</td>
    <td id=centeredRow>✅</td>
    <td id=centeredRow>❌</td>
  </tr>
</tbody>
</table>

## Non-collected Data

**_AdswizzSDK_** library suite does not fall under the following categories provided by Apple and therefore no data is currently collected for:

* Health and fitness
* User content
* Body
* Surroundings
* Diagnostics
* Usage data
* Purchases
* Search history
* Browsing history
* Contacts
* Sensitive info
* Financial info
* Contact info
