//
//  AppModel+AdswizzSDK.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 30.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation
import AdswizzSDK

/// Configure and initialize`AdswizzSDK`
extension AppModel {
    func configureAdswizzSDK() {
        AdswizzSDK.shared.delegate = self
        do {
            /// By default, we'll initialize the AdswizzSDK with the Adswizz keys in the Info.plist bundle.
            let plistSettings = AdswizzSDKInit()
            let config = AdswizzSDKConfig(playerId: plistSettings.playerId,
                                          installationId: plistSettings.installationId,
                                          appStoreId: plistSettings.appStoreId)
            try AdswizzSDK.shared.initialize(with: config)
            Log.info(
                    """
                     AdswizzSDK initialized with:
                      - installationId = \(plistSettings.installationId),
                      - playerId = \(plistSettings.playerId),
                      - appStoreId = \(plistSettings.appStoreId)
                    """)
            setupAdswizzSDK()
        } catch {
            Log.error(error)
        }
    }
    
    /// Optional setup for `AdswizzSDK`.
    func setupAdswizzSDK() {
        /// Set companion banner general settings
        let companionOptions = AdCompanionOptions()
        companionOptions.extraExposureTime = 0 //in seconds
        companionOptions.preferredResourceType = .firstResourceAvailable
        AdswizzSDK.setAdCompanionOptions(companionOptions)

        /// Handle privacy policies such as GDPR, CCPA or GPP consent
        AdswizzSDK.shared.gdprConsent = .notApplicable
        AdswizzSDK.shared.ccpaConfig = AdswizzCCPAConfig.Builder().build() //not applicable
        AdswizzSDK.shared.gppConsent = "<your GPP consent string>"
        
        /// Location settings if applicable
        AdswizzSDK.shared.locationAccuracy = 100 //in meters
        AdswizzSDK.shared.enableLocationSignificantChanges = true
    }
    
    func configureAnalytics() {
        /// Here you can setup the Analytics capabilities from AdswizzSDK such as adding your own `AnalyticsConnector`.
        //AdswizzSDK.shared.add(connector: yourAnalyticsConnector)
        //...
    }
    
}

/// Conform `AppModel` to `AdswizzSDKDelegate`
extension AppModel: AdswizzSDKDelegate {
    func adswizzSDKRecordingStarted(_ adswizzSDK: AdswizzSDK) {
        Log.info("Received recording started")
    }
    
    func adswizzSDKRecordingStopped(_ adswizzSDK: AdswizzSDK) {
        Log.info("Received recording stopped")
    }
}
