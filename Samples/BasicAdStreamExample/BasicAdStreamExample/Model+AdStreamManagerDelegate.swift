//
//  Model+AdStreamManagerDelegate.swift
//  BasicAdStreamExample
//
//  Created by Teodor Cristea on 12/02/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzSDK
import AVFoundation

extension Model: AdStreamManagerDelegate {
    func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL) {
        print("Received ad stream manager event: willStartPlaying -> \(url)")
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakStarted manager: AdManager) {
        print("Received ad stream manager event: adBreakStarted")
        adBreakManager = manager
        adBreakManager?.delegate = self // register for notification on this AdManager
        adBreakManager?.interactiveDelegate = self // register for interactive ads notifications
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakEnded manager: AdManager) {
        print("Received ad stream manager event: adBreakEnded")
        adBreakManager?.delegate = nil
        adBreakManager?.interactiveDelegate = nil
        adBreakManager = nil
    }

    func adStreamManager(_ adstreamManager: AdStreamManager, stateChanged state: MediaPlayerStatus) {
        print("Received ad stream manager event: stateChanged -> \(state)")
    }
        
    func adStreamManager(_ adstreamManager: AdStreamManager, metadataChanged metadata: [AVMetadataItem]) {
        print("Received ad stream manager event: metadataChanged")
    }
    
    func adStreamManagerWillReconnect(_ adstreamManager: AdStreamManager) {
        print("Received ad stream manager event: willReconnect")
    }
    
    func adStreamManagerPlayerShouldPause(_ adstreamManager: AdStreamManager) {
        print("Received ad stream manager event: playerShouldPause")
    }
    
    func adStreamManagerPlayerShouldResume(_ adstreamManager: AdStreamManager) {
        print("Received ad stream manager event: playerShouldResume")
    }
}
