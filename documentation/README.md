# **AdswizzAdSDK - Integration**
   * [<strong>Get started</strong>](#get-started)
      * [Prerequisites](#prerequisites)
      * [Dependencies](#dependencies)
      * [Adding the SDK to your Xcode project](#adding-the-sdk-to-your-xcode-project)
      * [Changes in your Info.pList file](#changes-in-your-infoplist-file)
      * [Changes to your app distribution](#changes-to-your-app-distribution)
      * [Your first ad request](#your-first-ad-request)
      * [Working with AdManager object](#working-with-admanager-object)
   * [<strong>Companion Banner</strong>](#companion-banner)
      * [Adding an AdCompanionView](#adding-an-adcompanionview)
      * [Setting up](#setting-up)
      * [Companion events](#companion-events)
      * [Extra exposure time for an AdCompanionView](#extra-exposure-time-for-an-adcompanionview)
   * [<strong>Interactive ads</strong>](#interactive-ads)
      * [Voice enabled interactive ads](#voice-enabled-interactive-ads)
      * [Handling voice recording](#handling-voice-recording)
      * [Handling interactive ad events](#handling-interactive-ad-events)
   * [<strong>Debugging AdswizzAdSDK</strong>](#debugging-adswizzadsdk)
   * [<strong>Playing ads using your player</strong>](#playing-ads-using-your-player)
      * [MediaPlayerState protocol](#mediaplayerstate-protocol)
         * [currentDuration](#currentduration)
         * [currentPlayHead](#currentplayhead)
         * [metadataItem](#metadataitem)
         * [playerStatus](#playerstatus)
   * [<strong>AdManager life cycle</strong>](#admanager-life-cycle)
      * [AdManager operations](#admanager-operations)
      * [AdManager protocol](#admanager-protocol)
         * [prepare](#prepare)
         * [play](#play)
         * [pause](#pause)
         * [skipAd](#skipad)
         * [reset](#reset)

# Get started

AdswizzAdSDK helps integrating Adswizz interactive ads in your application in a client side scenario. In a client side insertion your app will request ads from Adswizz ad server and you will decide when to play them.


## Prerequisites



*   Xcode 10+
*   Swift 5.0+ if the integration app uses Swift or ObjC
*   CocoaPods(preferred) or DropBox link for the framework binaries


## Dependencies

AdswizzAdSDK on iOS depends on 2 external libraries to support voice recognition (Amazon’s AWSCore and Facebook’s SocketRocket). These dependencies are automatically added if you choose to integrate the SDK using CocoaPods. If choose the manual integration you will have to provide them at link time.


## Adding the SDK to your Xcode project



1. Using CocoaPods 

    You can easily integrate AdswizzAdSDK in your project. If you already have a pod file just the following line:
    ```ruby
    pod 'AdswizzAdSDK', :git => "https://github.com/adswizz/ad-sdk-ios.git" 
    ```
    With the Podfile modified just run `pod install`. You will be prompted to enter security credentials to access the AdswizzAdSDK repository. These credentials will be provided by an Adswizz PIM. If the login was successful, external dependencies will be added automatically. These dependencies include Amazon’s AWSCore library and Facebook’s SocketRocket. These are required for voice detection in interactive ads.

2. Manual

    Unzip the content of the DropBox link. You will get the AdswizzAdSDK.framework binary and it’s corresponding dSYM file and bcsymbolmap file. Drop the AdswizzAdSDK.framework file in your project Frameworks directory. Make sure AdswizzAdSDK.framework is present in the “Embedded Binaries” section in your target. Make sure to add AWSCore.framework and SocketRocket.framework in your project as well.



## Changes in your Info.pList file

With the addition of the AdswizzAdSDK.framework to your application you will need to add some keys to the Info.pList. Let’s split these in 2 categories.


1. Settings for the framework:
    1. Add "**_AdswizzAdSDKInstallationId_**" string setting. This is a unique string provided by an Adswizz PIM. This setting **is mandatory** and if not set in your app’s Info.pList the initialize method of the AdswizzAdSDK will throw an error.
    <img src="img/installationId.png" width="1000" />
    
    2. Add "**_AdswizzAdSDKAWSIdentityPoolIdRegion_**" string setting. It is a string in the format "aws_region:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx" and will be provided by an Adswizz PIM. This setting is **not mandatory**, but if not set it will affect voice detection during interactive ads.
    <img src="img/aws.png" width="1000" />

2. Settings for permissions(**required**):
    1. Add **_NSCalendarsUsageDescription_** entry. While playing an interactive ad the SDK might trigger a “Calendar” action which will need access at the calendar.
    2. Add **_NSContactsUsageDescription_** entry. While the “Calendar” action presents the event you might want to invite people.
    3. Add **_NSLocationWhenInUseUsageDescription_** entry. Adswizz SDK might want to track the location while the app is in foreground for a better targetability. 
    4. Add **_NSLocationAlwaysAndWhenInUseUsageDescription_** entry. Adswizz SDK might want to track the location while the app is in the background and foreground for a better targetability. 
    5. Add **_NSMicrophoneUsageDescription_** entry. While an interactive ad will play with voice detection the SDK will require access to the microphone to record.
    6. Add **_NSSpeechRecognitionUsageDescription_** entry. While an interactive ad will play with voice detection the SDK will require access to Speech Kit to convert voice to text.
    7. Add **_NSPhotoLibraryUsageDescription_** entry. Adswizz SDK might want to save images in the library during an interactive ad.
    <img src="img/InfoPList.png" width="1000" />


## Changes to your app distribution

AdswizzAdSDK.framework is a fat library(both simulator and device binaries are bundled together). When you upload your app in the AppStore you will need to strip down the simulator part from the AdswizzAdSDK.framework. To do that go to your target’s app “Build Phases” page and tap on “New Run Script Phase” option. Paste the following script.


```bash
if [ "$CONFIGURATION" == "Debug" ]; then
echo "Skip frameworks cleaning in debug version"
exit 0
fi

APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# This script loops through the frameworks embedded in the application and
# removes unused architectures.
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

EXTRACTED_ARCHS=()

for ARCH in $ARCHS
do
echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
done
```



## Your first ad request

First, you need to configure the AdswizzAdSDK. The recommended way to do that is in your **_AppDelegate_** class on **_didFinishLaunchingWithOptions_** function. Here is a snippet of what this might look like:


```swift
import UIKit
import AdswizzAdSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
......
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  do {
     try AdswizzAdSDK.shared.initialize()
  } catch {
     print(error)
  }
.......
}
.......
}
```


An Adswizz PIM will provide you a unique sdk installation id which you need to add in your Info.pList under **_AdswizzAdSDKInstallationId_** key. You are now ready for your first ad request. You will need to create an **_AdswizzAdRequest_** object and configure it.


```swift
var adRequest: AdswizzAdRequest!
do {
      adRequest = try AdswizzAdRequest.Builder()
            	.with(server: "SERVER_PROVIDED_BY_PIM")
            	.with(zoneId: "ZONEID_PROVIDED_BY_PIM")
            	.with(playerId: "PLAYERID_PROVIDED_BY_PIM")
            	.build()
} catch {
     print(error)
}
```


Ad server, zoneId and playerId will be provided to you by an Adswizz PIM. 

After this point you need create an **_AdRequestConnection_** object and call requestAds with the ad request object.


```swift
let adRequestConnection = AdRequestConnection(for: adRequest)
adRequestConnection.requestAds { [weak self] adManager, error in
     self?.didReceiveResponse(adManager, error)
}
```


As a result of this call the SDK will provide you with an error if the call was a failure or an **_AdManager_** object if the result was a success.


## Working with AdManager object

If the request to the Adswizz Ad server was a success the SDK will return an **_AdManager_** object which you will own and will be the way the SDK will communicate events back to your application. To get this communication channel open you need to set up a delegate for the **_AdManager_** that conforms to the **_AdManagerDelegate_** protocol. The **_AdManager_** will call 

`func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent)` whenever events of interest might happen in the SDK. Consult AdEventType enum for a list of possible events from the AdswizzAdSDK. If an error happens in the SDK while using this object `func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error)` will be called.

As a first step, an **_AdManager_** needs to have some settings. You can create an **_AdManagerSettings_** object and pass it to your newly created instance of **_AdManager_**. In this object you can specify if you want to play the ad with the SDK’s internal player or a player of your choice that must conform to **_MediaPlayerState_** protocol.

Next, you need to call prepare method on the **_AdManager_** object. This will buffer the ads if you decide the play them with the internal player. Here is how it looks like.


```swift
import AdswizzAdSDK

class YourModelClass: AdManagerDelegate {
   var adManager: AdManager?
.....
func didReceiveResponse(_ adManager: AdManager?, _ error: Error?) {
    ......
    self.adManager = adManager   // Keep a strong reference of this object
    adManager?.delegate = self   // Get notifications from the Ad SDK
    let settings = AdManagerSettings() // Not required
    //settings.player = yourPlayer     // Optional
    adManager?.prepare()   // Start buffering the ads in the AdManager
}
......



......
func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
    switch event.event {
      case .didFinishLoading:
           adManager.play() //Start playing the next ad in the AdManager
    	case .didFinishPlaying:
        	break // Current ad has finished playing
    	case .allAdsDidFinishPlaying:
            break // All ads from the AdManager have finished
      default:
          break
    }
}
......
}
```


To actually start the **_AdManager_** rolling the ads you must call the play method on the **_AdManager_** when deciding to use the internal player. If you provide the player than you only need to start playing the ad in your player and the AdswizzAdSDK will observe the **_MediaPlayerState_** interface and decide when the ad has finished. In this case, calling **_adManager.play()_** is not necessary.


# Companion Banner

AdswizzAdSDK lets you configure companion banner(s) if you are provided by the Adswizz PIM with a companion zone id.


## Adding an AdCompanionView

Companion views can be added from storyboard/xib when you ad a view. Just specify the class **_AdCompanionView_**. You could also add the view programmatically. Once created, the SDK will keep track of all of your companion views and fill them with ad related content as the ad is playing.


## Setting up

First when you create an **_AdswizzAdRequest_** you must configure the **_companionZones_** with the value provided by the PIM.


```swift
adRequest = try AdswizzAdRequest.Builder()
            	.with(server: "SERVER_PROVIDED_BY_PIM")
            	.with(zoneId: "ZONEID_PROVIDED_BY_PIM")
            	.with(playerId: "PLAYERID_PROVIDED_BY_PIM")
                .with(companionZones: "COMPANION_PROVIDED_BY_PIM")
                .build()
```


Once the request is made, if there is a companion associated with the ad it will be loaded into your **_AdCompanionView_** object.


## Companion events

You can associate a delegate to your **_AdCompanionView_** that conforms to the **_AdCompanionViewDelegate_** protocol. You will be notified when the ad has loaded the companion view, if the companion view was displayed, or if it ended the display. If there was an error while loading the companion you will be notified through this delegate. Also, you can decide whether or not to override click through on the companion view. 

You can also deactivate companion view temporarily by setting the **_active_** member to false. 


## Extra exposure time for an AdCompanionView

By default the AdCompanionView will end displaying the content after the ad finishes playing. If you need to keep the companion on the screen for a longer time(or indefinitely) you can configure it like this.


```swift
let adCompanionOptions = AdCompanionOptions()
adCompanionOptions.extraExposureTime = 1.2 // these are seconds.
// if you need the companion forever on the screen
// adCompanionOptions.extraExposureTime = .greatestFiniteMagnitude
AdswizzAdSDK.setAdCompanionOptions(adCompanionOptions)
```



# Interactive ads

Adswizz interactive ads require some permissions on your app. Please refer to the “Changes in you Info.pList” section to add the necessary changes.


## Voice enabled interactive ads

To use voice interactive ads there are some dependencies on third party libraries (Amazon’s **AWSCore.framework** and Facebook’s **SocketRocket.framework**). Also, in Info.pList you need to add a string key called **_AdswizzAWSIdentityPoolIdRegion_** with the content received from an Adswizz PIM. Failing to add this key will reduce the ability of voice detection while your app is in the background.


## Handling voice recording

Apple recommends that your app’s UI reflect when recording started or stopped. AdswizzAdSDK provides a way to notify your app that recording has begun/stopped. Here is  what you need:


```swift
extension AppDelegate: AdswizzAdSDKDelegate {
    func configureAdswizzSDK() {
       AdswizzAdSDK.initialize(installationId: "YOUR_INSTALLATION_ID")
       AdswizzAdSDK.setDelegate(self)
    }
   
   func adswizzSDKRecordingStarted(_ adswizzSDK: AdswizzAdSDK) {
       // Update your UI to reflect that the SDK is recording
   }

   func adswizzSDKRecordingStopped(_ adswizzSDK: AdswizzAdSDK) {
       // Update your UI to reflect that the SDK is not recording anymore
   }
}
```



## Handling interactive ad events

While the **_AdMangerDelegate_** provides a list of **_AdEventType_** covering the life cycle of an ad it does not provide information on an interactive ad. To get more insight on what is happening while an interactive ad is playing you can set the **_interactiveDelegate_** on the **_AdManager_**. While implementing **_InteractiveAdManagerDelegate_** you will need to provide code to present a PKAddPassesViewController in case the AdswizzAdSDK needs to save a coupon in the Wallet.


```swift
class YourModelClass {
......
func didReceiveResponse(_ adManager: AdManager?, _ error: Error?) {
    ......
    // Get interactive ad notifications from the SDK
    adManager?.interactiveDelegate = self
    ......
 }
......
extension YourModelClass: InteractiveAdManagerDelegate {
func interactiveAdManager(_ adManager: AdManager, shouldPresentCoupon pkpassData: Data) {
    do {
        	let receivedPass = try PKPass(data: data)
        	if let vc = PKAddPassesViewController(pass: receivedPass) {
               // Here you can present the view controller
            } 
    } catch {
    }
}
    
func interactiveAdManager(_ adManager: AdManager, didReceiveAdEvent event: InteractiveAdEvent) {
  switch event.event {
    case .willBeSkipped:
     // Ad will be skipped as a result of an action during interactive ad
     break
    case .skipped:
     // Ad was skipped as a result of an action during interactive ad                 
     break
    case .extended:
     // Ad was extended with a new media as a result of an action
     break
    default:
      break
    }
}
}
```



# Debugging AdswizzAdSDK

The SDK uses an internal logger called **_AdLogger_**. By default the log level is set to none, meaning nothing gets logged. If you need more information from the SDK you can enable a different log level, verbose being the lower one (not recommended though in production). You can also provide a new destination for the logger (e.g.: pipe it to your app logger). By default SDK log event get dumped in the console.


```swift
extension AppDelegate: AdswizzAdSDKDelegate {
    func configureAdswizzSDK() {
      ......
      AdLogger.shared.level = .info
      AdLogger.shared.destination = self
      ......
    }
}
......
extension AppDelegate: AdLoggerDestination {
  func log(_ level: AdLogger.Level, functionName: String, fileName: String, lineNumber: Int, line: String) {
      //Pipe it to your logger
  }
}
```



# Playing ads using your player

AdswizzAdSDK gives you the possibility to choose whether to play the ad media with your player or let the SDK handle that for you. By default, the SDK will play the ad. If you need to take control of the playing you must configure the **_AdManager_** object received after an **_AdConnectionRequest_** with a new **_AdManagerSettings_** object. You can provide here your player that must conform to **_MediaPlayerState_** protocol. This protocol will notify the SDK of changes in the player through KVO. Here is how you setup a player.


```swift
class YourModelClass {
    var yourPlayer: YourPlayer
......
func didReceiveResponse(_ adManager: AdManager?, _ error: Error?) {
    ......
    // Get interactive ad notifications from the SDK
    Let adManagerSettings = AdManagerSettings()
    adManagerSettings.player = yourPlayer
    adManager?.adManagerSettings = adManagerSettings
    ......
 }
......

class YourPlayer: NSObject, MediaPlayerState {
    @objc dynamic public var currentPlayhead: TimeInterval = 0
    @objc dynamic public var playerStatus = MediaPlayerStatus.initialized
    @objc dynamic public var metadataItem: [AVMetadataItem]?
    @objc public var currentDuration: TimeInterval = 0
}
```


Let’s break down the MediaPlayerState protocol.


## MediaPlayerState protocol
### currentDuration

Your player needs to inform the AdswizzAdSDK of the current duration of the media as soon as possible. The media duration is required to compute quartile events or progress events in the SDK. If it is **not possible** to report the media duration just **set it to 0**. If the SDK reads 0 from currentDuration it will rely on the VAST response media file duration. If the VAST duration is missing as well the quartile/progress events will be triggered at the end of the media player in the correct order but not when they actually happened.


### currentPlayHead

For a good reporting of the quartile/progress events your player should update where the player is at from the whole ad duration. It is **recommended** that your player should update this value at an interval of **1 second**. Going below this might trigger performance issues. If your player skips forward or backwards as the ad is playing, update this member accordingly to reflect the action taken. This will affect the way quartile events are fired by the SDK.


### metadataItem

If your player can read metadata from the media that is playing it should report it through this member. While not necessary for a client side insertion it makes more sense when you are playing a stream.


### playerStatus

While your player is playing the ad it should update this member so that AdswizzAdSDK start monitoring the status of the ad through your player. **Failing to update** this member accordingly will not generate the desired events from **_AdManager_** object.  Upon receiving the ad url from the AdManager on **_willStartLoading_** event in 


```swift
func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent)
```


put your player in **_initialized_** state. If your player cannot load the url the player should report **_failure_** state. It can however, set this state during the playing if an error occurred and it does not make sense to continue with this ad. When setting **_failure_** or **_unknown_** as the state of your player the SDK will terminate the current ad sent in **_willStartLoading_** and inform your app that the media player state is unknown. The AdManager will move to the next ad if available.

If your player is buffering data you can report that to the SDK by setting the state to buffering. If your done **_buffering_** report **_bufferingFinished_**. Reporting **_buffering_** and **_bufferingFinished_** ensures that quartile/progress events are reported correctly and are not subject to network interruptions. If your player is ready to play the ads(it might not have yet buffered enough data) it can report a state of **_readyToPlay_**, meaning the player’s play method might be called. This state is optional and it resembles AVPlayer currentItem readyToPlay status. If your player started playing set the state to **_playing_**. If you pause the playing set the state to **_pause_**. **Resume** presumes the state to change to **_playing_** again. When the player has finished playing the ad set the state to **_finished_**.

Here is a state machine for your player to implement.
<img src="img/MediaPlayerState.png" width="1000" />


# AdManager life cycle

After requesting your first ad from Adswizz ad server you are ready to play the ads from the AdManager object. Keep in mind you might receive more than one ad from the server but you are not obligated to play them all. If you decide to play multiple ads in your app you need to listen to the events AdManager sends to your app and decide what is the appropriate action to take. Here is a diagram of the AdManager state.



## AdManager operations

Once presented with an AdManager one could call different actions on the AdManager. Let’s break them down.

## AdManager protocol
### prepare

You call this method to begin to cycle through the ads in the AdManager. If you decided to let the SDK handle the playing of the ads this method ensures that the internal player is starting to buffer enough data so that ad playing starts smoothly. After calling this method the first ad is beginning to load. The SDK will trigger **_willStartLoading_** event informing your app that buffering has begun for the ad. If the SDK is playing the ad you will also get **_didFinishLoading_** event for the first ad. If you are playing the ad you will not get this message as your player is responsible to start the buffering process.


### play

If you decided to let the SDK play the ads you will need to call **_play_** method on **_didFinishLoading_**(recommended). Calling this method while you are handling the ad playing has no effect in the SDK. You can call this method after you paused the AdManager to resume playing. AdManager will trigger a **_didStartPlaying_** event back to your app for confirmation.


### pause

If you decided to let the SDK play the ads you can call **_pause_** method whenever you need to stop playing the ads in the AdManager. Calling this method while you are handling the ad playing has no effect in the SDK. AdManager will trigger a **_didPausePlaying_** event back to your app for confirmation.


### skipAd

If you need to skip an ad you can call this method to skip the current ad from the AdManager. This method applies even if you decided to take control of the ad playing. Your app will receive a **_didFinishPlaying_** event for the current ad and if the AdManager has a new ad you will receive **_willStartLoading_** for that one. If no ads are available an **_allAdsDidFinishPlaying_** will be sent, signaling that all ads got processed in the AdManager.


### reset

If you decide to skip all ads in the AdManager from the current one you can call this method. For each ad skipped your app will trigger **_didFinishPlaying_** and a **_allAdsDidFinishPlaying_** event will be sent at the end. Looping through the ad again will need a call to **_prepare_** function.
<img src="img/AdManagerState.png" width="1000" />
