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
        if isUsingExternalPlayer {
            player.prepare(with: url)
            player.play()
        }
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakStarted manager: AdManager) {
        print("Received ad stream manager event: adBreakStarted")
        adBreakManager = manager
        adBreakManager?.delegate = self // register for notification on this AdManager
        adBreakManager?.interactiveDelegate = self // register for interactive ads notifications
        // Ad manager started playing the ad(s)
        adBreakDelegate?.modelDidStartAdBreak(self)
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakEnded manager: AdManager) {
        print("Received ad stream manager event: adBreakEnded")
        adBreakManager?.delegate = nil
        adBreakManager?.interactiveDelegate = nil
        adBreakManager = nil
        // Ad manager just finished playing (all) ad(s)
        adBreakDelegate?.modelDidEndAdBreak(self)
    }

    func adStreamManager(_ adstreamManager: AdStreamManager, stateChanged state: MediaPlayerStatus) {
        print("Received ad stream manager event: stateChanged -> \(state.toString)")
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

extension MediaPlayerStatus {
    var toString: String {
        switch self {
        case .initialized: return "initialized"
        case .buffering: return "buffering"
        case .bufferingFinished: return "bufferingFinished"
        case .readyToPlay: return "readyToPlay"
        case .playing: return "playing"
        case .paused: return "paused"
        case .finished: return "finished"
        case .failed: return "failed"
        case .unknown: return "unknown"
        @unknown default:
            return "unknown"
        }
    }
}
