//
//  ViewController+AdManagerDatasource.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 20/01/2021.
//  Copyright © 2021 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzSDK

extension ViewController: AdManagerDatasource {
    //Called when AdswizzSDK fires urls for VAST tracking events. See `VastTrackingEvent` enum for possible event values.
    func adManager(_ adManager: AdManager, ad: AdData, trackingEventUrls event: VastTrackingEvent) -> [URL] {
        print("ad manager: \(adManager) requested trackingEventUrls ad: \(ad.id ?? "unknown") event: \(event.stringValue)")
        return generateTrackingUrls(for: "event/\(event.stringValue)")
    }
    
    //Called when AdswizzSDK fires urls for VAST errors. See `VastErrorCode` enum for possible error values.
    func adManager(_ adManager: AdManager, ad: AdData, trackingErrorUrls errorCode: VastErrorCode) -> [URL] {
        print("ad manager: \(adManager) requested trackingErrorUrls ad: \(ad.id ?? "unknown") code: \(errorCode)")
        return generateTrackingUrls(for: "error/\(errorCode)")
    }
    
    //Called when AdswizzSDK fires urls for impression tracking.
    func adManagerImpressionUrls(_ adManager: AdManager, ad: AdData) -> [URL] {
        print("ad manager: \(adManager) requested impressionUrls ad: \(ad.id ?? "unknown")")
        return generateTrackingUrls(for: "impression")
    }
}

//Helpers to generate custom tracking URLs
//to be fired by AdswizzSDK along with VAST tracking URLs.
private extension ViewController {
    var customTrackingUrl: String {
        return "https://www.adswizz.com/tracking/[TYPE]/[INDEX]/macros/state=[PLAYERSTATE]&adCount=[ADTYPE]"
    }
    
    func generateTrackingUrls(for type: String, count: Int = 1) -> [URL] {
        var urls: [URL] = []
        (0..<count).forEach {
            urls.append(URL(string: customTrackingUrl.replacingOccurrences(of: "[TYPE]", with: type)
                                .replacingOccurrences(of: "[INDEX]", with: "\($0 + 1)"))!)
        }
        return urls
    }
}

extension VastTrackingEvent {
    var stringValue: String {
        switch self {
        case .mute: return "mute"
        case .unmute: return "unmute"
        case .pause: return "pause"
        case .resume: return "resume"
        case .rewind: return "rewind"
        case .skip: return "skip"
        case .playerExpand: return "playerExpand"
        case .playerCollapse: return "playerCollapse"
        case .notUsed: return "notUsed"
        case .loaded: return "loaded"
        case .start: return "start"
        case .firstQuartile: return "firstQuartile"
        case .midpoint: return "midpoint"
        case .thirdQuartile: return "thirdQuartile"
        case .complete: return "complete"
        case .progress: return "progress"
        case .closeLinear: return "closeLinear"
        case .creativeView: return "creativeView"
        case .acceptInvitation: return "acceptInvitation"
        case .adExpand: return "adExpand"
        case .adCollapse: return "adCollapse"
        case .minimize: return "minimize"
        case .close: return "close"
        case .overlayViewDuration: return "overlayViewDuration"
        case .otherAdInteraction: return "otherAdInteraction"
        case .unknown:
            fallthrough
        @unknown default:
            return "unknown"
        }
    }
}
