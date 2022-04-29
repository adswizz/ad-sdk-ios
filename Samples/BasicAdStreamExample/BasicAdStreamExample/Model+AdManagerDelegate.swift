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
        case .preparingForPlay:
            // The companion information for current ad can be check early in the ad events succession
            // by using the `hasCompanion` property on `AdData`
            event.ad?.printCompanionInformation()
        case .readyForPlay:
            adManager.play() //necessary, if there is more than one ad in the manager
        case .didStartPlaying:
            //current ad in AdManager is playing
            break
        case .allAdsCompleted:
            // Ad manager just finished playing (all) ad(s)
            break
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

extension AdData {
    func printCompanionInformation() {
        if hasCompanion {
            print("[Companion] has information for AdId: \(id ?? "unknown")")
        } else {
            print("[Companion] <<none>>")
        }
    }
}
