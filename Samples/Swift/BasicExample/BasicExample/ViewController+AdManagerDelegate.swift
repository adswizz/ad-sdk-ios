//
//  UIViewController+AdManagerDelegate.swift
//  BasicExample
//
//  Created by Teodor Cristea on 17/09/2019.
//  Copyright © 2019 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzAdSDK

extension ViewController: AdManagerDelegate {
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }
    
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager: \(adManager) triggered ad event: \(event.stringEvent)")
        
        switch event.event {
        case .didFinishLoading:
            // Ad manager finished loading ad(s)
            // Before playing the ads you should pause your own content
            pauseContent()
            
            // Start playing ad(s)
            self.adManager?.play()
            
        case .didStartPlaying:
            // Ad manager started playing the ad(s)
            // Show a companion ad which will automatically be synced with the ad
            if let view = companionView, view.superview == nil {
                self.view.addSubview(view)
                let views = ["view": view]
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", metrics: [:], views: views as [String : Any]))
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0@900-[view]-0@900-|", metrics: [:], views: views as [String : Any]))
                
                let height = NSLayoutConstraint.init(item: view,
                                                     attribute: .height,
                                                     relatedBy: .equal,
                                                     toItem: view,
                                                     attribute: .width,
                                                     multiplier: 1.0,
                                                     constant: 0)
                let centerX = NSLayoutConstraint.init(item: view,
                                                      attribute: .centerX,
                                                      relatedBy: .equal,
                                                      toItem: self.view,
                                                      attribute: .centerX,
                                                      multiplier: 1.0,
                                                      constant: 0)
                let centerY = NSLayoutConstraint.init(item: view,
                                                      attribute: .centerY,
                                                      relatedBy: .equal,
                                                      toItem: self.view,
                                                      attribute: .centerY,
                                                      multiplier: 1.0,
                                                      constant: 0)
                self.view.addConstraints([height, centerX, centerY])
            }
            
        case .didFinishPlaying, .allAdsDidFinishPlaying:
            // Ad manager just finished playing (all) ad(s)
            // Resume content
            playContent()
            
            // Cleanup
            self.adManager = nil
            
        default:
            break
        }
    }
}
