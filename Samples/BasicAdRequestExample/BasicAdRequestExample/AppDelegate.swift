//
//  AppDelegate.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 16/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import UIKit
import AdswizzSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize AdswizzSDK.
        // Note that AdswizzSDK expects the following in your app's info.plist:
        //  1. an installationId
        //  2. a playerId
        // More details in AdswizzSettingsKeys.
        do {
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

