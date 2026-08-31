//
//  UIViewController+AdManagerDelegate.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 17/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzSDK
import AdswizzExamplesCommon

extension ViewController: @MainActor AdManagerDelegate {
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
            
            if externalPlayerSwitch.isOn {
                guard
                    let mediaFile = event.ad?.asset.mediaUrl,
                    let mediaFileURL = URL(string: mediaFile)
                    else {
                         print("Could not build the url for ad media!")
                         break
                     }
                externalPlayerSwitch.isUserInteractionEnabled = false
                externalPlayer.prepare(with: mediaFileURL)
            }
        case .readyForPlay:
            // Ad manager finished loading ad(s)
            // Before playing the ads you should pause your own content
            pauseContent()

            if externalPlayerSwitch.isOn {
                // Play the ad(s) with your own player
                externalPlayer.play()
            } else {
                // Start playing ad(s)
                self.adManager?.play()
                
                externalPlayerSwitch.isUserInteractionEnabled = false
            }
            
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
            self.adManager = nil
            externalPlayer.stop()
            externalPlayerSwitch.isUserInteractionEnabled = true
        default:
            break
        }
    }
}

