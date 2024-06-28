# AdswizzSDK - iOS Swift

The only audio-centric SDK to Drive Innovation & Differentiation in Audio monetization

## Requirements

* Xcode 15.2+ or newer
* iOS 13.0+
* Swift 5.9+

## Dependencies
AdswizzSDK.framework depends on the following frameworks:
* AdswizzSDKPrivacyData.framework (1.0.7)

`AdswizzSDKPrivacyData.framework` is a source library which implements Privacy-Sensitive API that requires user permission. AdswizzSDKPrivacyData.framework can be configured to exclude any sensitive API at built time.

> **Note**
> `AWSCore.framework` became an optional dependency for **_AdswizzSDK_**. For more details, visit the documentation for **_AdswizzSDKPinpointAnalytics_** and the migration docs to **7.8.0 and later**.

## Installation

### Swift Package Manager

To be able to install **_AdswizzSDK_** using Swift Package Manager, please follow the steps detailed below.

#### Authentication

**_AdswizzSDK_** is delivered as an .xcframework from a private Github repository, and as a result, Swift Package Manager needs to be instructed to checkout the binary files using a Github token. You can obtain a token from your AdsWizz partner integration manager. 

Since Xcode 13.3, Swift Package Manager has official support for binary frameworks which are vended from a private Github release. For more details, you can read the discussions on the official [thread](https://forums.swift.org/t/spm-support-basic-auth-for-non-git-binary-dependency-hosts/37878) which started in June 2020.

Next, let's set up the Swift Package Manager authentication mechanism. Please choose one of the authentication methods below.

##### .netrc

The `.netrc` file format is commonly used for the automatic authentication of HTTP requests and usually placed in the user’s home directory (`~/.netrc`). Learn more about netrc by reading the [gnu documentation](https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html).

To use the `.netrc` authentication, make sure you have it under your home directory. If you don't have a .netrc file, go ahead and create one:

```ruby
touch ~/.netrc
```
...and add the following inside:

```ruby
machine github.com login adswizz password ADSWIZZ_GITHUB_TOKEN
```

Replace **_ADSWIZZ_GITHUB_TOKEN_** with your token received from AdsWizz.

##### Apple's Keychain

Even though `.netrc` is a great solution which works on Mac and also on Linux, if the integration is done exclusively on Mac (and most **_AdswizzSDK_** integrators do) then your application can leverage Apple's Keychain as alternative. Instead of creating an entry in the `~/.netrc` file, create an internet password instead containing:
- Keychain Item Name: `api.github.com`
- Account Name: GitHub user name
- Password: The personal access token supplied by your Adswizz Technical Account Manager

Xcode (SPM) will read from your Keychain once the permission is granted. Such a dialogue may come up during package resolution.
<img src="../img/xcode_keychain_access.png" width="500" />

Once you've completed the authentication setup by choosing one of the methods above, let's add the **_AdswizzSDK_** Swift package and its dependencies.

#### Package installation

1. Swift Package Manager is distributed with Xcode. To start adding the **_AdswizzSDK_** to your iOS project, open your project in Xcode and select File > Add Package Dependencies... or select your project in the "Project Navigator" panel, navigate to the "Package Dependencies" tab and click the "+" button. Xcode will open the "Add Package Dependency" dialog.

2. Enter the following URL for the **_AdswizzSDK_** for iOS Swift Package Manager GitHub repo into the search bar:
```ruby
https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios
```
Replace ADSWIZZ_GITHUB_TOKEN with the token you received from AdsWizz.
3. You'll see the repository rules for which version of the **_AdswizzSDK_** you want Swift Package Manager to install. Choose the `Up to Next Major Version` as it will use the latest compatible version of the dependency that can be detected from the main branch. Select which project you want Swift Package Manager to add the **_AdswizzSDK_**, then click "Add Package".
4. Choose which of the libraries you want added to your project target. Always select the **_AdswizzSDK_** product. The remaining library products to install are optional (depending on your application needs), but they all rely on **_AdswizzSDK_** main binary framework.

Select all that are appropriate, then click "Add Package(s)" for Xcode to resolve the package(s) and link them into your project.
Next, let's also add the **_AdswizzSDK_** mandatory dependency.

#### AdswizzSDKPrivacyData dependency

**_AdswizzSDKPrivacyData_** is a helper framework for **_AdswizzSDK_** on iOS, that has all the Privacy-Sensitive API required by **_AdswizzSDK.xcframework_**. **_AdswizzSDKPrivacyData_**'s purpose is to facilitate the interoperability with **_AdswizzSDK_** and to allow your app to manage sensitive APIs (such as permission APIs) without adding unwanted permission usage decription strings in the app's Info.plist manifest. It is a transparent way to communicate to **_AdswizzSDK_** all your app-specific Privacy needs and constraints.

**_AdswizzSDK_** distributed through Swift Package Manager relies on the **_AdswizzSDKPrivacyDataCore.xcframework_** as mandatory dependency. 
Install it via Swift Package Manager, by repeating the installation steps 1 - 4 from above, but this time enter the following URL for the **_AdswizzSDKPrivacyData_** Swift Package Manager GitHub repo into the search bar:
```ruby
https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios-privacydata-core
```
Same as before, replace ADSWIZZ_GITHUB_TOKEN with the same token you used for the **_AdswizzSDK_** Swift package.
Again, you'll see the dependency rules for which version of the **_AdswizzSDKPrivacyData_** you want Swift Package Manager to install. Choose `Branch` and use the latest version on the `main` branch.
For **_AdswizzSDKPrivacyData_** you will be presented with a list of libraries you want added to your project target. Always select the **_AdswizzSDKPrivacyDataCore_** product.
The other products are optional and you can opt-in and select the ones matching the permissions your app is using. 
> For example, if your app asks for the tracking permission, you should select the **_AdswizzSDKPrivacyDataIDFA_** product and link it to your project's target. This enables **_AdswizzSDK_** to access the ATT framework and use the IDFA identifier for listening context and better targeting. 
Another example, if you plan to leverage AdsWizz's interactive audio ad formats, **_AdswizzSDK_** will need access to the microphone and speech permissions so you should also include the **_AdswizzSDKPrivacyDataMicrophone_** and **_AdswizzSDKPrivacyDataSpeech_** products into your project's target.

#### AWSCore dependency

The AWSCore dependency is not needed if you only install **_AdswizzSDK_** (and optionally **_AdswizzWatchSDK_**). However, if you also chose to install and link your project against **_AdswizzSDKPinpointAnalytics_** framework, you'll also need to install the [AWSCore Swift Package](https://github.com/aws-amplify/aws-sdk-ios) dependency from aws-amplify.

### Cocoapods

**_AdswizzSDK_** is delivered as an xcframework, and it can easily be integrated through Cocoapods. The recommended version for Cocoapods is 1.13.0 or newer. If you already have a pod file, you just need to add the following lines:
```ruby
pod 'AdswizzSDKPrivacyData', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios-privacydata.git", :tag => '1.0.7'
pod 'AdswizzSDK',            :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git" 
```
Replace **_ADSWIZZ_GITHUB_TOKEN_** with token you received from AdsWizz. You can obtain a token from your AdsWizz partner integration manager. After modifying the podfile, run `pod install`. You will be prompted to enter a username. Enter any valid email address. Don't leave this value empty or the install will fail. When prompted for password enter the token repository provided by AdsWizz. Once authorization is successful, external dependencies will be added automatically. Since AdswizzSDK.framework is built using BUILD_LIBRARY_FOR_DISTRIBUTION = YES, all Swift dependencies must be built the same way. This includes AdswizzSDKPrivacyData.framework. As a [workaround](https://github.com/CocoaPods/CocoaPods/issues/9232), you need to add a post_install hook in your Podfile:

```ruby
post_install do |installer|
   installer.pods_project.targets.each do |target|
        if target.name == "AdswizzSDKPrivacyData"
         target.build_configurations.each do |config|
          path = config.base_configuration_reference.real_path
          update_xcconfig(path, { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES"
# Exclude senstive API. Uncomment the line bellow and exclude what permission you don't want to add to your app.            
#                               , "SWIFT_ACTIVE_COMPILATION_CONDITIONS" => "NO_SPEECH_ACCESS NO_CONTACTS_ACCESS NO_CALENDAR_ACCESS NO_CAMERA_ACCESS NO_LOCATION_ACCESS NO_MICROPHONE_ACCESS NO_MOTION_ACTIVITY_ACCESS"
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

### Carthage

**_AdswizzSDK_** can also be installed using Carthage. The recommended version for carthage is 0.38.0 or newer. 

#### Step 1: Cartfile

Type in the following lines inside your Cartfile:

```ruby
binary "https://raw.githubusercontent.com/adswizz/ad-sdk-ios/master/AdswizzSDK.json"
github "https://github.com/adswizz/ad-sdk-ios-privacydata.git"
```

> **Note**
> Same as for the Cocoapods installation, the `AWSCore` external library is not required anymore. Thus, the line `github "aws-amplify/aws-sdk-ios"` from your Cartfile can be removed.

#### Step 2: Authentication

Because AdswizzSDK is kept under a private repository, we need to provide an authentication mechanism to access it. We'll use .netrc for it. If you don't have a .netrc file under your home directory create one:

```ruby
touch ~/.netrc
```

and add the following 2 lines to it: 

```ruby
machine github.com login adswizz password ADSWIZZ_GITHUB_TOKEN
machine raw.githubusercontent.com login adswizz password ADSWIZZ_GITHUB_TOKEN
```

Replace **_ADSWIZZ_GITHUB_TOKEN_** with your token received from AdsWizz. 

#### Step 3: Custom Carthage run script

We need to run a custom script for Carthage. On the same level as the `Cartfile` create a new file called `carthage.sh` and give it execution rights:

```ruby
touch carthage.sh
chmod +x carthage.sh
```

And copy the following contents to in it:

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

#### Step 4: Run 

We're now ready to install the **_AdswizzSDK_** with Carthage. As a last step we need to specify a file that contains all the flags needed to compile the AdswizzSDKPrivacyData Framework. 
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

### Manually

If you prefer not to use any of the supported dependency managers above, you can integrate **_AdswizzSDK_** into your project manually.

#### Embedded Framework

Unzip the content of the DropBox link. The unzipped content should contain the following:

```
AdswizzSDK.xcframework binary
AdswizzSDKCore.xcframework binary
AdswizzWatchSDK.xcframework binary
AdswizzSDKPinpointAnalytics.xcframework binary
```

Drop the **_AdswizzSDK.xcframework_** and **_AdswizzSDKCore.xcframework_** packages in your project `Frameworks` group/folder. Make sure **_AdswizzSDK.xcframework_** and **_AdswizzSDKCore.xcframework_** are present in the “Embedded Binaries” section in your target.
**_AdswizzSDK_** also needs to link the following .framework:

```
AdswizzSDKPrivacyData.framework
```
Make sure to add it in your project as well.
**_AdswizzSDKPrivacyData.framework_** can be added as a submodule from https://github.com/adswizz/ad-sdk-ios-privacydata repo and selecting the appropriate tag. Next, you need to add **_AdswizzSDKPrivacyData.xcodeproj_** to your workspace or project. If you choose to add the xcodeproj from the repo you will need to add a step to make **_AdswizzSDKPrivacyData.xcodeproj_** compile. By design, **_AdswizzSDKPrivacyData.xcodeproj_** needs a **_CustomConfig.xcconfig_** in the **_AdswizzSDKPrivacyData_** project directory. This file is placed in .gitignore so you need to copy or create it every time you build or archive your scheme. To achive this you can create a **_New Run Script Action_** in your scheme's **_Build_** section or **_Archive_** section.

1. If you don't want to create a custom xcconfig file add:
```
"<YOUR_SUBMODULE_LOCATION>/AdswizzSDKPrivacyData/AdswizzSDKPrivacyData/CreateCustomConfig.sh"
```
This will create an empty **_CustomConfig.xcconfig_** in submodule directory.

2. If you want to create a custom xcconfig file add:
```
yes | cp -rf "<YOUR_LOCATION>/<CUSTOM_FILE>.xcconfig" "<YOUR_SUBMODULE_LOCATION>/AdswizzSDKPrivacyData/CustomConfig.xcconfig"
```
In this example, <CUSTOM_FILE>.xcconfig is a xcconfig file kept in your repo, and you just copy it in the ad-sdk-ios-privacydata repo.

You can add the same step to the **_Archive_** section as well.

## Releases

Check out the [releases section](https://github.com/adswizz/ad-sdk-ios/releases) for downloadable zips of the SDK.

## License

This SDK is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

