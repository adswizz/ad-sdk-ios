# AdswizzSDK - iOS Swift

The only audio-centric SDK to Drive Innovation & Differentiation in Audio monetization

## Requirements

* Xcode 11+ or newer
* iOS 11.0+
* Swift 5.0+
* CocoaPods 1.9.3+ (recommended)

## Dependecies
AdswizzSDK.framework dependes on the following frameworks:
* AWSCore.framework
* SocketRocket.framework
* SwiftProtobuf.framework
* AdswizzSDKPrivacyData.framework (1.0.6)

AdswizzSDKPrivacyData.framework is an open source library which implements Privacy-Sensitive API that requires user permission. AdswizzSDKPrivacyData.framework can be configured to exclude any sensitive API at built time.

## Installation

### CocoaPods

AdswizzSDK is delivered as an xcframework, so the best way to integrate it is through Cocoapods. The recommended version for Cocoapods is 1.9.3 or newer. If you already have a pod file, you just need to add the following line:
```ruby
pod 'AdswizzSDK', :git => "https://ADSWIZZ_GITHUB_TOKEN@github.com/adswizz/ad-sdk-ios.git" 
```
Replace **_ADSWIZZ_GITHUB_TOKEN_** with token you received from AdsWizz. You can obtain a token from your AdsWizz partner integration manager. After modifying the podfile, run `pod install`. You will be prompted to enter a username. Enter any valid email address. Don't leave this value empty or the install will fail. When prompted for password enter the token repository provided by AdsWizz. Once authorization is successful, external dependencies will be added automatically. These dependencies include Amazon’s AWSCore library, Facebook’s SocketRocket and SwiftProtobuf. Since AdswizzSDK.framework is built using BUILD_LIBRARY_FOR_DISTRIBUTION = YES, all Swift dependencies must be built the same way. This includes SwiftProtobuf.framework and AdswizzSDKPrivacyData.framework. As a [workaround](https://github.com/CocoaPods/CocoaPods/issues/9232), you need to add a post_install hook in your Podfile:

```ruby
post_install do |installer|
   installer.pods_project.targets.each do |target|
       if target.name == "SwiftProtobuf"
         target.build_configurations.each do |config|
           path = config.base_configuration_reference.real_path
           update_xcconfig(path, { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES" })
         end
       elsif target.name == "AdswizzSDKPermissions"
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

### Manually

If you prefer not to use any of the supported dependency managers above, you can integrate AdswizzSDK into your project manually.

#### Embedded Framework

Unzip the content of the DropBox link. The unzipped content should contain the following:

```
AdswizzSDK.xcframework binary
```

Drop the AdswizzSDK.xcframework file in your project Frameworks directory. Make sure AdswizzSDK.xcframework is present in the “Embedded Binaries” section in your target.
AdswizzSDK also needs to link the following .frameworks:

```
AWSCore.framework
SocketRocket.framework
SwiftProtobuf.framework
AdswizzSDKPrivacyData.framework
```
Make sure to add those in your project as well.
AdswizzSDKPrivacyData.framework can be added as a submodule from https://github.com/adswizz/ad-sdk-ios-privacydata repo and selecting the appropriate tag. Next, you need to add AdswizzSDKPrivacyData.xcodeproj to your workspace or project. If you choose to add the xcodeproj from the repo you will need to add a step to make AdswizzSDKPrivacyData.xcodeproj compile. By design, AdswizzSDKPrivacyData.xcodeproj needs a **_CustomConfig.xcconfig_** in the AdswizzSDKPrivacyData project directory. This file is placed in .gitignore so you need to copy or create it every time you build or archive your scheme. To achive this you can create a **_New Run Script Action_** in your scheme's **_Build_** section or **_Archive_** section.

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

