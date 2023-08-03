//
//  AppDelegate.swift
//  ExternalPlayer
//
//  Created by Bogdan Cosescu on 20/04/2020.
//  Copyright © 2020 Adswizz. All rights reserved.
//

import UIKit
import AdswizzSDK
import AdswizzSDKCore

let kLog: AppLogger = AppDelegate.logger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let logger = AppLogger()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
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
        } catch {
            kLog.log(error.localizedDescription)
        }
        
        //Let's set the logging level in AdswizzSDK to verbose.
        AdLogger.shared.level = .verbose
        AdLogger.shared.destination = kLog
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
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
