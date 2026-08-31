//
//  ExternalMediaPlayerApp.swift
//  ExternalPlayerExample
//
//  Created by George Mihoc on 20.01.2026.
//  Copyright © 2026 Adswizz. All rights reserved.
//

import SwiftUI
import AdswizzSDK
import AdswizzSDKCore
import AdswizzExamplesCommon

let kLog = AppLogger()

@main
struct ExternalMediaPlayerApp: App {
    
    init() {
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
            print(error as NSError)
        }
        
        //Let's set the logging level in AdswizzSDK to verbose.
        AdLogger.shared.level = .verbose
        AdLogger.shared.destination = kLog
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

