# AdswizzSDK - iOS Swift

The only audio-centric SDK to Drive Innovation & Differentiation in Audio monetization

## Requirements

* Xcode 10.2 or newer
* iOS 11.0+
* Swift 5.0+
* CocoaPods (recommended)

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate AdswizzSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'AdswizzSDK', :git => "https://github.com/adswizz/ad-sdk-ios.git"
```
Since AdswizzSDK.framework is built using BUILD_LIBRARY_FOR_DISTRIBUTION = YES, all Swift dependencies must be built the same way. As a [workaround](https://github.com/CocoaPods/CocoaPods/issues/9232), you need to add a post_install hook in your Podfile:

```ruby
post_install do |installer|
 installer.pods_project.targets.each do |target|
     # propagate 'BUILD_LIBRARY_FOR_DISTRIBUTION' build setting
     if target.name == "SwiftProtobuf"
       target.build_configurations.each do |config|
           xcconfig_path = config.base_configuration_reference.real_path
           # read from xcconfig to build_settings dictionary
           build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.split(/\s*=\s*/, 2)}.flatten]
           build_settings["BUILD_LIBRARY_FOR_DISTRIBUTION"] = 'YES'
           # write build_settings dictionary to xcconfig
           File.open(xcconfig_path, "w") do |file|
             build_settings.each{ |k, v|
               file.write("#{k} = #{v}")
             }
           end
       end
     end
 end
end
```

### Manually

If you prefer not to use any of the supported dependency managers above, you can integrate AdswizzSDK into your project manually.

#### Embedded Framework

Unzip the content of the DropBox link. The unzipped content should contain the following:

```
* AdswizzSDK.framework binary
* AdswizzSDK.dSYM file
* coresponding .bcsymbolmap file
```

Drop the AdswizzSDK.framework file in your project Frameworks directory. Make sure AdswizzSDK.framework is present in the “Embedded Binaries” section in your target.
AdswizzSDK also needs to link the following .frameworks:

```
AWSCore.framework
SocketRocket.framework
SwiftProtobuf.framework
```
Make sure to add those in your project as well.

## Releases

Check out the [releases section](https://github.com/adswizz/ad-sdk-ios/releases) for downloadable zips of the SDK.

## License

This SDK is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
