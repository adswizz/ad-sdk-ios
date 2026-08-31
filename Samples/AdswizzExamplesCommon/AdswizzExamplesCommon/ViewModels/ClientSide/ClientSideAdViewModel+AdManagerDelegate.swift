//
//  ClientSideAdViewModel+AdManagerDelegate.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK

extension ClientSideAdViewModel: AdManagerDelegate {
    public func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }

    public func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager: \(adManager) triggered ad event: \(event.stringEvent)")

        switch event.event {
        case .preparingForPlay:
            event.ad?.printCompanionInformation()

            if useExternalPlayer, let mediaFile = event.ad?.asset.mediaUrl, let mediaFileURL = URL(string: mediaFile) {
                externalPlayerSwitchEnabled = false
                externalPlayer?.prepare(with: mediaFileURL)
            }

        case .readyForPlay:
            // Before playing the ads, pause your own content
            pauseContent()
            onCompanionStateChanged(hasCompanion: event.ad?.hasCompanion ?? false)

            if useExternalPlayer {
                externalPlayer?.play()
            } else {
                self.adManager?.play()
                externalPlayerSwitchEnabled = false
            }

        case .didStartPlaying:
            isPlaying = true

        case .allAdsCompleted:
            // Resume content
            playContent()
            onAllAdsCompleted()

            // Cleanup
            self.adManager = nil
            externalPlayer?.stop()
            externalPlayerSwitchEnabled = true
            isPlaying = false

        default:
            break
        }

        // Forward to subclass hook
        onAdEvent(event)
    }

    public func adManager(_ adManager: AdManager, ad: AdData, didChangedPlayHead playHead: TimeInterval, adDuration duration: TimeInterval) {
        onPlayheadChanged(ad: ad, playHead: playHead, duration: duration)
    }
}
