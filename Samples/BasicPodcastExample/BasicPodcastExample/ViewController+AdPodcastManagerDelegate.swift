//
//  ViewController+AdPodcastManagerDelegate.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 14.02.2022.
//

import Foundation
import AdswizzSDK

extension ViewController: AdPodcastManagerDelegate {
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didFailPlaying url: URL, error: Error) {
        print("Failed to play podcast at \(url) with error \(error.localizedDescription)")
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, willStartPlaying url: URL) {
        print("Will play podcast at \(url)")
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didReceive manager: AdManager) {
        print("AdBreaks loaded")
        print("Received AdManager adCount=\(manager.adCount) \(manager.totalAdsDuration)")

        /* // If custom player available
        if player != nil {
            let settings = AdManagerSettings()
            settings.player = playerForAdBreak
            manager.adManagerSettings = settings
        }
        */
        adBreakManager = manager
        adBreakManager?.delegate = self
        adBreakManager?.interactiveDelegate = self
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, stateChanged state: MediaPlayerStatus) {
        
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, playheadChanged playhead: TimeInterval, duration: TimeInterval) {
        print("Playhead changed \(playhead) out of total duration \(duration)")
        currentDuration = duration
        updateSeekBarLabels(playhead, currentDuration)
    }
    
    func adPodcastManagerPlayerShouldPause(_ adPodcastManager: AdPodcastManager) {
        
    }
    
    func adPodcastManagerPlayerShouldResume(_ adPodcastManager: AdPodcastManager) {
        
    }
    
    func adPodcastManagerPlayer(_ adPodcastManager: AdPodcastManager, shouldSeekTo time: TimeInterval, completion: @escaping () -> Void) {
        
    }
}
