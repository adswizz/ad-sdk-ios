//
//  Model+AdManagerDelegate.swift
//  BasicAdStreamExample
//
//  Created by Teodor Cristea on 17/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzSDK

extension Model: AdManagerDelegate {
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }
    
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager: \(adManager) triggered ad event: \(event.stringEvent)")
        
        switch event.event {
        case .didStartPlaying:
            // Ad manager started playing the ad(s)
            adBreakDelegate?.modelDidStartAdBreak(self)
            
        case .didFinishPlaying, .allAdsDidFinishPlaying:
            // Ad manager just finished playing (all) ad(s)
            adBreakDelegate?.modelDidEndAdBreak(self)
            
        default:
            break
        }
    }
}

extension Model: InteractiveAdManagerDelegate {
    func interactiveAdManager(_ adManager: AdManagerOwner, shouldPresentCoupon pkpassData: Data) {
    }
    
    func interactiveAdManager(_ adManager: AdManagerOwner, didReceiveAdEvent event: InteractiveAdEvent) {
    }
}
