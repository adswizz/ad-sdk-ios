# React Native support (beta)

React Native generated projects need a few modifications in order to interface with the AdswizzSDK. This is due in part to how the AdswizzSDKPrivacyData framework works and due to the fact that the SDK dynamically links with dependant frameworks.

## Step 1

Turn on dynamic linking. One way of doing this is to replace the line

```bash
import AdswizzSDK
```

with 

```bash
linkage = ENV['USE_FRAMEWORKS']
```

After this change, flipper must be disabled
```bash
    #:flipper_configuration => flipper_config,
```

## Step 2

Add Adswizz post install hook to configure the AdswizzSDKPrivacyFramework.

Under the line: 

```bash
    __apply_Xcode_12_5_M1_post_install_workaround(installer)
```

Append the AdswizzSDK post hook install method:
```bash
    __apply_Xcode_12_5_M1_post_install_workaround(installer)
    adswizzPostInstall(installer)
```

And afterwards, add these two methods at the end of the podfile:

```bash
def adswizzPostInstall(installer)
    installer.pods_project.targets.each do |target|
         if target.name == "AdswizzSDKPrivacyData"
          target.build_configurations.each do |config|
           path = config.base_configuration_reference.real_path
           update_xcconfig(path, { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES",
                                   "SWIFT_ACTIVE_COMPILATION_CONDITIONS" => "NO_CONTACTS_ACCESS NO_CALENDAR_ACCESS NO_CAMERA_ACCESS NO_LOCATION_ACCESS NO_MOTION_ACTIVITY_ACCESS"})
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

##Step 3

Add the AdswizzSDK pod and run ```pod install``` in the terminal. Congratulations ! You have integrated the AdswizzSDK in a React Native project !

## Converting the AppDelegate to swift

The generated project contains an Objective-C AppDelegate file and main.m file. Optionally, the project can be converted to use an AppDelegate.swift file. 

### Step 1

Remove the ```AppDelegate.h```, ```AppDelegate.mm```, ```main.m``` files. Add a new file called ```AppDelegate.swift```. Click "Create Bridging Header" when prompted. 

### Step 2

In the bridging header, input the following lines:

```swift
#import <React/RCTBridgeModule.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTRootView.h>
#import <React/RCTUtils.h>
#import <React/RCTConvert.h>
#import <React/RCTBundleURLProvider.h>
```

### Step 3

In the ```AppDelegate.swift```, input the following content:

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var bridge: RCTBridge!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let jsCodeLocation: URL

    jsCodeLocation = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index", fallbackExtension: nil)
    let rootView = RCTRootView(bundleURL: jsCodeLocation, moduleName: "###PROJECT_NAME###", initialProperties: nil, launchOptions: launchOptions)
    let rootViewController = UIViewController()
    rootViewController.view = rootView

    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.rootViewController = rootViewController
    self.window?.makeKeyAndVisible()

    return true
  }
}
```
