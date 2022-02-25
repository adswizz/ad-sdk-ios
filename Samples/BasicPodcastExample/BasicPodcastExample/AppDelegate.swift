//
//  AppDelegate.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 10.02.2022.
//

import UIKit
import AdswizzSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize AdswizzSDK.
        // Note that unless AdswizzSDK was initialized programmatically with the config object, it expects the following in your app's info.plist:
        //  1. an installationId
        //  2. a playerId
        // More details in AdswizzSettingsKeys.
        do {
            //optional, initialize AdswizzSDK by passing the playerId and installationId through the AdswizzSDKConfig object and override values in Info.plist (if needed)
            //let config = AdswizzSDKConfig(playerId: "yourPlayerId", installationId: "yourInstallationId")
            //try AdswizzSDK.shared.initialize(with: config)
            try AdswizzSDK.shared.initialize()
        } catch {
            print(error as NSError)
        }

        // Set optional settings for AdswizzSDK.
        // You can set/change them at any time and the SDK will update accordingly.
        
        // Set the companion banner to stay on screen longer than default (0 seconds).
        // This setting takes effect when the ad(s) finished playing.
        let options = AdCompanionOptions()
        options.extraExposureTime = 5 // in seconds
        // Set preferred resource type for companion banner and AdswizzSDK will attempt to match the desired resource.
        // This setting takes effect when the ad(s) start playing and AdswizzSDK selects the media resource to render it for the created companion(s).
        // Otherwise it defaults to first valid resource.
        options.preferredResourceType = .html // default value is .firstResourceAvailable
        AdswizzSDK.setAdCompanionOptions(options)
        
        // You may want to pass the GDPR consent status if it applies to your app.
        // You can set the .gdprConsent property whenever you have the info available from your users.
        // Defaults to .notApplicable which means the rules of the GDPR do not apply.
        AdswizzSDK.shared.gdprConsent = .granted
        
        // Same as .gdprConsent, through the .ccpaConfig
        // you define the U.S privacy string if it applies to your app.
        // Defaults to .notApplicable which means the rules of the CCPA do not apply.
        AdswizzSDK.shared.ccpaConfig = AdswizzCCPAConfig.Builder()
            .with(explicitNotice: .yes)
            .with(optOut: .no)
            .with(lspa: .yes)
            .build()
        
        // These settings affect how the SDK handles location if permission is granted at any time.
        // Otherwise they have no effect.
        AdswizzSDK.shared.locationAccuracy = 1000.0 // in meters
        AdswizzSDK.shared.enableLocationSignificantChanges = false
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

