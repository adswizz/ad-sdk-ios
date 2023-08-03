# Get started

The AdswizzSDK facilitates the ad lifecycle management, right from your application. 
Sensing listeners environment, it crafts the overall ad experience for superior addressability and augmented interactivity.

Additionally, in a client-side insertion scenario, it retrieves the ad with its associated assets, and handles the reporting operations.<br>
In a server-side insertion scenario, it takes the pressure off your app by making the interactivity and assets easily available.


## Prerequisites

*   Xcode 12+
*   Swift 5.0+ if the integration app uses Swift or Objective-C
*   Framework binaries - either via CocoaPods 1.9.3+, Carthage or archive (manual integration)

## Changelog

Please check [here](iOS/CHANGELOG.md) the latest AdswizzSDK version and all new changes & fixes it comes with. 

## Dependencies

AdswizzSDK.framework depends on the following framework:
* AdswizzSDKPrivacyData.framework (1.0.6)

*AdswizzSDKPrivacyData* is a source library which implements Privacy-Sensitive API which requires user permission. *AdswizzSDKPrivacyData* can be configured to exclude any sensitive API at build time.
This dependency is automatically added if you choose to integrate the SDK using CocoaPods. If you choose the Carthage or manual integration you will have to provide it at link time.


## Adding the SDK to your Xcode project

1. Using CocoaPods 

    The AdswizzSDK is delivered as an xcframework, so the best way to integrate it is through Cocoapods. The recommended version for Cocoapods is 1.9.3 or newer. If you already have a pod file, you just need to add the following lines:
    ```ruby
    pod 'AdswizzSDKPrivacyData', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios-privacydata.git", :tag => '1.0.6'
    pod 'AdswizzSDK',            :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git" 
    ```
    Replace **_ADSWIZZ_GITHUB_TOKEN_** with the token you received from AdsWizz. You can obtain a token from your AdsWizz partner integration manager. After modifying the podfile, run `pod install`. You will be prompted to enter a username. Enter any valid email address. Don't leave this value empty or the install will fail. When prompted for a password, enter the token repository provided by AdsWizz. Once authorization is successful, external dependencies will be added automatically. Since the AdswizzSDK.framework is built using BUILD_LIBRARY_FOR_DISTRIBUTION = YES, all Swift dependencies must be built the same way. This includes the AdswizzSDKPrivacyData.framework. As a [workaround](https://github.com/CocoaPods/CocoaPods/issues/9232), you need to add a post_install hook in your Podfile:
    
    ```ruby
    post_install do |installer|
       installer.pods_project.targets.each do |target|
            if target.name == "AdswizzSDKPrivacyData"
             target.build_configurations.each do |config|
              path = config.base_configuration_reference.real_path
              update_xcconfig(path, { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES"
    # Exclude senstive API. Uncomment the line bellow and exclude what permission you don't want to add to your app.            
    #                               , "SWIFT_ACTIVE_COMPILATION_CONDITIONS" => "NO_IDFA_ACCESS NO_SPEECH_ACCESS NO_CONTACTS_ACCESS NO_CALENDAR_ACCESS NO_CAMERA_ACCESS NO_LOCATION_ACCESS NO_MICROPHONE_ACCESS NO_MOTION_ACTIVITY_ACCESS"
                                    })
             end
           end
       end
    end

    def update_xcconfig(path, new_values)
      build_settings = Hash[*File.read(path).lines.map{|x| x.split(/\s*=\s*/, 2)}.flatten]
      new_values.each { |k, v|
        build_settings[k] = "#{v}\n"
      }
      File.open(path, "w") do |file|
        build_settings.each{ |k, v|
          file.write("#{k} = #{v}")
        }
      end
    end
    ```

2. Carthage

    The AdswizzSDK can also be delivered using Carthage. The recommended version for carthage is 0.38.0 or newer. 

    1. Cartfile

      Type in the following lines inside your Cartfile:

    ```ruby
    binary "https://raw.githubusercontent.com/adswizz/ad-sdk-ios/master/AdswizzSDK.json"
    github "aws-amplify/aws-sdk-ios"
    github "https://github.com/adswizz/ad-sdk-ios-privacydata.git"
    ```
    > **Note**
    > The `github "aws-amplify/aws-sdk-ios"` line is only needed if you also consider integrating **_AdswizzSDKPinpointAnalytics_**. For more details, please visit the [Integrating AdswizzSDK Pinpoint Analytics](iOS/SDKPinpointAnalytics/IntegratingAdswizzSDKPinpointAnalytics) section. 

    2. Authentication

      Because the AdswizzSDK is under a private repository, it needs an authentication mechanism to access it. We'll use .netrc for it. If you don't have a .netrc file under your home directory, go ahead and create one:

    ```ruby
    touch ~/.netrc
    ```

      and add the following inside: 

    ```ruby
    machine github.com login adswizz password ADSWIZZ_GITHUB_TOKEN
    machine raw.githubusercontent.com login adswizz password ADSWIZZ_GITHUB_TOKEN
    ```

      Replace **_ADSWIZZ_GITHUB_TOKEN_** with your token received from AdsWizz. 

    3. Custom Carthage run script

      We need to run a custom script for Carthage. On the same level as the Cartfile, create a new file and give it execution rights:

    ```ruby
    touch carthage.sh
    chmod +x carthage.sh
    ```

      Copy the following contents to it:

    ```ruby
	# !/usr/bin/env bash
	# carthage.sh
	# Usage example: ./carthage_with_flags.sh CustomFlags.xcconfig

	if [ "$#" -ne 1 ]; then
   		echo "Usage example: ./carthage_with_flags.sh CustomFlags.xcconfig"
   		exit -1
	fi

	customConfigFilename=$1

	if [ -e $1 ]
	then
    	echo "Found file named ${customConfigFilename}."
	else
    	echo "File ${customConfigFilename} does not exist!"
    	exit -2
	fi

	set -euo pipefail
	xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
	trap 'rm -f "$xcconfig"' INT TERM HUP EXIT
	# For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
	# the build will fail on lipo due to duplicate architectures.
	echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
	echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' > $xcconfig

	export XCODE_XCCONFIG_FILE="$xcconfig"
	carthage update --no-build --use-netrc # checkout

	cp -f $customConfigFilename "Carthage/Checkouts/ad-sdk-ios-privacydata/AdswizzSDKPrivacyData/CustomConfig.xcconfig"
	echo -e "" > "Carthage/Checkouts/ad-sdk-ios-privacydata/AdswizzSDKPrivacyData/AdswizzSDKPrivacyData/CreateCustomConfig.sh"

	carthage build --use-netrc --use-xcframeworks
    ```

    4. Run
    
      We're now ready to install the AdswizzSDK with Carthage. As a last step we need to specify a file that contains all the flags needed to compile the AdswizzSDKPrivacyData Framework. 
      This file can look like:
      
       ```swift
    		SWIFT_ACTIVE_COMPILATION_CONDITIONS=NO_CALENDAR_ACCESS NO_CAMERA_ACCESS NO_LOCATION_ACCESS NO_MOTION_ACTIVITY_ACCESS
   	   ```
          
   	  Or it can be empty if we want all the permission flags enabled for the AdswizzSDKPrivacyData framework.
          
      Run the following command and you're good to go: 

    ```ruby
    ./carthage.sh CustomConfig.xcconfig
    ```

      Notice that by using `./carthage.sh` we are running carthage from our own custom script.

3. Manual

    Unzip the AdswizzSDK archive, which contains the AdswizzSDK.xcframework binary. Drop the AdswizzSDK.xcframework file in your project’s Frameworks directory. Make sure that AdswizzSDK.xcframework is listed in the **_Embedded Binaries_** section of your target.<br>
    AdswizzSDKPrivacyData.framework can be added as a submodule from the https://github.com/adswizz/ad-sdk-ios-privacydata repo selecting the appropriate tag. Next, you need to add AdswizzSDKPrivacyData.xcodeproj to your workspace or project. If you choose to add the xcodeproj from the repo you will need to add a step to make AdswizzSDKPrivacyData.xcodeproj compile. By design, AdswizzSDKPrivacyData.xcodeproj needs a **_CustomConfig.xcconfig_** in the AdswizzSDKPrivacyData project directory. This file is placed in .gitignore so you need to copy or create it every time you build or archive your scheme. To achieve this, you can create a **_New Run Script Action_** in **your scheme's** **_Build_** section or **_Archive_** section.

    1. If you don't want to create a custom xcconfig file add:
    ```
    "<YOUR_SUBMODULE_LOCATION>/AdswizzSDKPrivacyData/AdswizzSDKPrivacyData/CreateCustomConfig.sh"
    ```
    This will create an empty **_CustomConfig.xcconfig_** in the submodule directory.

    2. If you want to create a custom xcconfig file add:
    ```
    yes | cp -rf "<YOUR_LOCATION>/<CUSTOM_FILE>.xcconfig" "<YOUR_SUBMODULE_LOCATION>/AdswizzSDKPrivacyData/CustomConfig.xcconfig"
    ```
    In this example, <CUSTOM_FILE>.xcconfig is a xcconfig file kept in your repo, and you just copy it in the ad-sdk-ios-privacydata repo.

    You can add the same step to the **_Archive_** section.

## Changes in your Info.pList file

After adding AdswizzSDK.xcframework to your application, unless you will pass the required settings programmatically when the AdswizzSDK is initialized (**_installationId_**, **_playerId_** and **_appStoreId_**), you’ll also need to add some keys in Info.pList. Let’s split these in to two categories:
For more details about these settings please consult [SDK initialization and setup](#sdk-initialization-and-setup).

1. Settings for the framework:
    1. Add "**_AdswizzAdSDKInstallationId_**" as a string setting. This is a unique string provided by your AdsWizz Integration Manager. If not provided programmatically, this setting is **mandatory** and, if not set in your app’s Info.pList, the initialize method of the AdswizzSDK will throw an error.
    <img src="../img/installationId.png" width="1000" />

    2. Add the "**_AdswizzAdSDKPlayerId_**" string setting. This is a unique string provided by your AdsWizz Integration Manager. If not provided programmatically, this setting is **mandatory** and, if not set in your app’s Info.pList, the initialize method of the AdswizzSDK will throw an error.
    <img src="../img/playerId.png" width="1000" />
    
    3. (Optional) Add the "**_AdswizzAdSDKAppStoreId_**" string setting. This value is an automatically generated ID assigned to your app in AppStore Connect. It can be found in your AppStore Connect page for your app under App Information -> General Information -> Apple ID. If not provided programmatically, this setting is **optional** and, if not set in your app’s Info.pList either, AdswizzSDK will not throw an error, however, during initialization, it will attempt to obtain the AppStoreId for your app using Apple's public lookup API call.
    <img src="../img/appStoreId.png" width="1000" />
    
2. Settings for permissions(**optional**):
    1. Add a **_NSCalendarsUsageDescription_** entry. There are interactive ads that, once acted upon, add events in the Calendar. If you don't want to add this entry use the **NO_CALENDAR_ACCESS** compilation switch for AdsiwzzSDKPrivacyData.framework either in the Podfile(if you use CocoaPods) or in the CustomConfig.xcconfig(manual installation).
    2. Add **_NSContactsUsageDescription_** entry. As events are added to the Calendar, the user might be interested in inviting friends along. For this, the SDK requires access to the Contacts. For this, the SDK requires access to the Calendar. If you don't want to add this entry use the **NO_CONTACTS_ACCESS** compilation switch for AdsiwzzSDKPrivacyData.framework either in the Podfile(if you use CocoaPods) or in the CustomConfig.xcconfig(manual installation).
    3. Add a **_NSLocationWhenInUseUsageDescription_** entry. One of the best targeting criteria for ads is users’ location. The SDK only updates location when in the foreground. For this, the SDK requires access to Location - While the app is in use. If you don't want to add this entry use the **NO_LOCATION_ACCESS** compilation switch for AdsiwzzSDKPrivacyData.framework either in the Podfile(if you use CocoaPods) or in the CustomConfig.xcconfig(manual installation).
    4. Add a **_NSLocationAlwaysAndWhenInUseUsageDescription_** entry. To enhance the location-based targeting capability, the SDK can leverage the location information when the app is running in background. For this, the SDK requires access to Location - Always. If you don't want to add this entry use the **NO_LOCATION_ACCESS** compilation switch for AdsiwzzSDKPrivacyData.framework either in the Podfile(if you use CocoaPods) or in the CustomConfig.xcconfig(manual installation).
    5. Add a **_NSMicrophoneUsageDescription_** entry. Interactive voice ads depend on the user being able to interact with the ad, through voice. For this, the SDK requires access to the Microphone. If you don't want to add this entry use the **NO_MICROPHONE_ACCESS** compilation switch for AdsiwzzSDKPrivacyData.framework either in the Podfile(if you use CocoaPods) or in the CustomConfig.xcconfig(manual installation).
    6. Add a **_NSSpeechRecognitionUsageDescription_** entry. Once the user interacts with an interactive voice ad, the SDK needs to convert voice into text, in order to comprehend the command. For this, the SDK will require access to SpeechKit. If you don't want to add this entry use the **NO_SPEECH_ACCESS** compilation switch for AdsiwzzSDKPrivacyData.framework either in the Podfile(if you use CocoaPods) or in the CustomConfig.xcconfig(manual installation).
    7. Add a **_NSPhotoLibraryUsageDescription_** entry. One of the actions users can perform on an interactive ad is saving a coupon or a banner to the photo library. For this, the SDK requires access to the Photo Library. If you don't want to add this entry use the **NO_PHOTO_ACCESS** compilation switch for AdsiwzzSDKPrivacyData.framework either in the Podfile(if you use CocoaPods) or in the CustomConfig.xcconfig(manual installation).
    8. Add a **_NSMotionUsageDescription_** entry. For better targetting AdsWizz can use CMMotionActivityManager to determine what aaccitivity is the user engaged in. For this, the SDK requires ccess to the device’s motion data. If you don't want to add this entry use the **NO_MOTION_ACTIVITY_ACCESS** compilation switch for AdsiwzzSDKPrivacyData.framework either in the Podfile(if you use CocoaPods) or in the CustomConfig.xcconfig(manual installation).
    9. Add a **_NSUserTrackingUsageDescription_** entry. If you want to use the AdswizzSDK tracking framework to assist you in asking users' consent for accessing IDFA, add this in your app's Info.plist. If you don't want to add this entry, use the **NO_IDFA_ACCESS** compilation switch for AdsiwzzSDKPrivacyData.framework either in the Podfile (if you use CocoaPods) or in the CustomConfig.xcconfig(manual installation).

    <img src="../img/InfoPList.png" width="1000" />



## SDK initialization and setup

To properly integrate the AdswizzSDK into your app, you first need to initialize the AdswizzSDK with an optional configuration.
There are two mandatory string settings that allow AdswizzSDK to be initialized properly: **_installationId_** and **_playerId_**. 
**_appStoreId_** is optional. If not provided, during initialization the SDK will attempt to fetch it remotely using Apple's public lookup API.

You can either set them in your Info.plist file with the **_AdswizzAdSDKInstallationId_** key, **_AdswizzAdSDKPlayerId_** and **_AdswizzAdSDKAppStoreId_** respectively (see [Changes in your Info.pList file](#changes-in-your-infoplist-file)), or set them programmatically in which case the Info.plist values will be overridden.

To programmatically set the **_installationId_**, **_playerId_** and **_appStoreId_** string settings you use a configuration object which is an instance of **_AdswizzSDKConfig_**.

The recommended place to initialize the AdswizzSDK is in your **_AppDelegate_** class on **_didFinishLaunchingWithOptions_** function. Here is a snippet of what this might look like:


```swift
import UIKit
import AdswizzSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
......
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  //the configuration object is optional, unless you want to override the Info.plist values
  //or simply didn't add the string settings in your app's Info.plist
  let config = AdswizzSDKConfig(playerId: "yourPlayerId", installationId: "yourInstallationId", appStoreId: "yourAppAppleID")
  do {
     try AdswizzSDK.shared.initialize(with: config)
  } catch {
     print(error)
  }
.......
}
.......
}
```


Your AdsWizz Integration Manager will provide you with unique SDK installation ids that you need to add in your Info.pList under the **_AdswizzSDKInstallationId_** key and **_AdswizzSDKPlayerId_** respectively. You are now ready for your first ad request in a client-side scenario, playing a live stream in the server-side insertion approach or playing podcasts.

