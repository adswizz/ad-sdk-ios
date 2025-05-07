//
//  AppDelegate.swift
//  BasicDVRRequestExample
//
//  Created by Adrian Manolache on 07.07.2021.
//

import UIKit
import AdswizzSDK
import AdswizzSDKCore

let kLog: AppLogger = AppDelegate.logger

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let logger = AppLogger()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Let's set the logging level in AdswizzSDK to verbose.
        AdLogger.shared.level = .verbose
        AdLogger.shared.destination = kLog

        // Initialize AdswizzSDK.
        // Note that unless AdswizzSDK was initialized programmatically with the config object, it expects the following in your app's info.plist:
        //  1. an installationId
        //  2. a playerId
        //  3. the appStoreId
        // More details in AdswizzSettingsKeys.
        do {
            //optional, initialize AdswizzSDK by passing the playerId, installationId and your application appStoreId through the AdswizzSDKConfig object to override values in the Info.plist (if needed)
            //note that if you don't provide the AppStore Id for your app, the AdswizzSDK will try to fetch it by using your app bundle id
            //let config = AdswizzSDKConfig(playerId: "yourPlayerId", installationId: "yourInstallationId")
            //try AdswizzSDK.shared.initialize(with: config)
            try AdswizzSDK.shared.initialize()
            kLog.log("Successfully initialized AdswizzSDK")
        } catch {
            kLog.log("Failed to initialize AdswizzSDK. Reason: \(error.localizedDescription)")
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

class AppLogger {
    func log(_ line: String) {
        print("App log: \(line)")
    }
}

extension AppLogger: AdLoggerDestination {
    func log(_ level: AdLogger.Level, functionName: String, fileName: String, lineNumber: Int, line: String) {
        print("AdswizzSDK log: \(line)")
    }
}
