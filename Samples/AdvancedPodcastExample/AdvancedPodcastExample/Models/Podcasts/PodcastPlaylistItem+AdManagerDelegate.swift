//
//  PodcastPlaylistItem+AdManagerDelegate.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 05.09.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation
import AdswizzSDK

extension PodcastPlaylistItem: AdManagerDelegate {
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        guard let ad = event.ad else {
            return
        }
        let hasCompanion = ad.hasCompanion
        switch event.event {
        case .didStartPlaying:
            adDelegate?.podcastPlaylistItem(self, didStartPlaying: ad, withCompanion: hasCompanion)
        case .didFinishPlaying:
            adDelegate?.podcastPlaylistItem(self, didEndPlaying: ad, withCompanion: hasCompanion)
        default:
            break
        }
    }
    
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        guard let ad = ad else {
            return
        }
        adDelegate?.podcastPlaylistItem(self, didEndPlaying: ad, withCompanion: ad.hasCompanion)
    }
}
