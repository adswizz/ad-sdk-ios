//
//  ServerSideAdViewModel+AdManagerDelegate.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK

extension ServerSideAdViewModel: AdManagerDelegate {
    public func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }

    public func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager: \(adManager) triggered ad event: \(event.stringEvent)")

        switch event.event {
        case .preparingForPlay:
            // The companion information for current ad can be check early in the ad events succession
            // by using the `hasCompanion` property on `AdData`
            event.ad?.printCompanionInformation()
            onCompanionStateChanged(hasCompanion: event.ad?.hasCompanion ?? false)
        case .readyForPlay:
            adManager.play() //necessary, if there is more than one ad in the manager
        case .allAdsCompleted:
            onAllAdsCompleted()
        default:
            break
        }

        // Forward to subclass hook
        onAdEvent(event)
    }
}
