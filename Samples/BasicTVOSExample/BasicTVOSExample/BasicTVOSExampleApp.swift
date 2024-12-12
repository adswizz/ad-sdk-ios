//
//  BasicTVOSExampleApp.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 18.11.2024.
//

import SwiftUI
import AdswizzSDK

@main
struct BasicTVOSExampleApp: App {
    
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
        
        // You may want to pass the GDPR consent status if it applies to your app.
        // You can set the .gdprConsent property whenever you have the info available from your users.
        // Defaults to .notApplicable which means the rules of the GDPR do not apply.
        AdswizzSDK.shared.consent.gdpr = .granted
        
        // Same as .gdprConsent, through the .ccpaConfig
        // you define the U.S privacy string if it applies to your app.
        // Defaults to .notApplicable which means the rules of the CCPA do not apply.
        AdswizzSDK.shared.consent.ccpa = AdswizzCCPAConfig.Builder()
            .with(explicitNotice: .yes)
            .with(optOut: .no)
            .with(lspa: .yes)
            .build()
        
        // These settings affect how the SDK handles location if permission is granted at any time.
        // Otherwise they have no effect.
        AdswizzSDK.shared.location.accuracy = 1000.0 // in meters
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
