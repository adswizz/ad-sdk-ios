//
//  BasicVideoAdExampleApp.swift
//  BasicVideoAdExample
//
//  Created by George Mihoc on 16.01.2026.
//

import SwiftUI
import AVFoundation
import AdswizzSDK

@main
struct BasicVideoAdExampleApp: App {
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }

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
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
