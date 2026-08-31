//
//  ViewController+AdManagerDatasource.swift
//  BasicUIKitClientSideInsertion
//
//  Created by George Mihoc on 22.04.2026.
//  Copyright © 2026 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzSDK
import AdswizzExamplesCommon

extension ViewController: @MainActor AdManagerDatasource {
    //Called when AdswizzSDK fires urls for VAST tracking events. See `VastTrackingEvent` enum for possible event values.
    func adManager(_ adManager: AdManager, ad: AdData, trackingEventUrls event: VastTrackingEvent) -> [URL] {
        print("ad manager: \(adManager) requested trackingEventUrls ad: \(ad.id ?? "unknown") event: \(event.stringValue)")
        return TrackingUrlGenerator.generateTrackingUrls(for: "event/\(event.stringValue)")
    }
    
    //Called when AdswizzSDK fires urls for VAST errors. See `VastErrorCode` enum for possible error values.
    func adManager(_ adManager: AdManager, ad: AdData, trackingErrorUrls errorCode: VastErrorCode) -> [URL] {
        print("ad manager: \(adManager) requested trackingErrorUrls ad: \(ad.id ?? "unknown") code: \(errorCode)")
        return TrackingUrlGenerator.generateTrackingUrls(for: "error/\(errorCode.rawValue)")
    }
    
    //Called when AdswizzSDK fires urls for impression tracking.
    func adManagerImpressionUrls(_ adManager: AdManager, ad: AdData) -> [URL] {
        print("ad manager: \(adManager) requested impressionUrls ad: \(ad.id ?? "unknown")")
        return TrackingUrlGenerator.generateTrackingUrls(for: "impression")
    }
    
    func adManagerCompanionClickTrackingUrls(_ adManager: AdManager, ad: AdData, _ companion: Companion) -> [URL] {
        print("ad manager: \(adManager) requested companionClicksUrls ad: \(ad.id ?? "unknown")")
        return TrackingUrlGenerator.generateTrackingUrls(for: "companionClicks")
    }
    
    func adManagerVideoClickTrackingUrls(_ adManager: AdManager, ad: AdData) -> [URL] {
        print("ad manager: \(adManager) requested videoClicksUrls ad: \(ad.id ?? "unknown")")
        return TrackingUrlGenerator.generateTrackingUrls(for: "videoClicks")
    }
}
