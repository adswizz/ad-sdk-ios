//
//  PodcastAdViewModel+AdManagerDelegate.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK

extension PodcastAdViewModel: AdManagerDelegate {
    public func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }

    public func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager triggered ad event: \(event.stringEvent)")

        switch event.event {
        case .preparingForPlay:
            onCompanionStateChanged(hasCompanion: event.ad?.hasCompanion ?? false)
        case .readyForPlay:
            adManager.play()
            showSkipAd = true
        case .adCompleted:
            onCompanionStateChanged(hasCompanion: false)
            showSkipAd = false
        case .allAdsCompleted:
            onAllAdsCompleted()
            adBreakManager = nil
        default:
            break
        }

        // Forward to subclass hook
        onAdEvent(event)
    }
}
