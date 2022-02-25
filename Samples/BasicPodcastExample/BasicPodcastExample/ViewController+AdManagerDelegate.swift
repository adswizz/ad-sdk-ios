//
//  ViewController+AdManagerDelegate.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 15.02.2022.
//

import Foundation
import AdswizzSDK

extension ViewController: AdManagerDelegate {
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }
    
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager: \(adManager) triggered ad event: \(event.stringEvent)")
        
        switch event.event {
        case .readyForPlay:
            // Ad manager finished loading ad(s)
            // Before playing the ads you should pause your own content
            pauseContent()
            
            // Start playing ad(s)
            self.adBreakManager?.play()
            
        case .didStartPlaying:
            // Ad manager started playing the ad(s)
            
            // Update Now Playing with a valid file URL and metadata
            if let firstFile = event.ad?.asset.mediaUrl, let firstFileURL = URL(string: firstFile) {
                updateNowPlaying(with: NowPlayableStaticMetadata(assetURL: firstFileURL,
                                                                 isLiveStream: false,
                                                                 title: "Adswizz Ad",
                                                                 artist: "Basic Ad Request",
                                                                 artwork: nil))
            }
            
        case .allAdsCompleted:
            // Ad manager just finished playing (all) ad(s)
            // Resume content
            playContent()
            
            // Cleanup
            self.adBreakManager = nil
            
        default:
            break
        }
    }
}
