//
//  ViewController+InteractiveAdManagerDelegate.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 15.02.2022.
//

import Foundation
import AdswizzSDK
import PassKit

extension ViewController: InteractiveAdManagerDelegate {
    
    /// This callback is triggered immediately after the coupon was downloaded (the download of the coupon may be triggered by a shake event).
    /// Give the host application a chance to take over the control for presenting coupons
    /// This callback is always triggered on the main thread.
    @objc func interactiveAdManager(_ adManager: AdManagerOwner, shouldPresentCoupon pkpassData: Data) {
        do {
              let receivedPass = try PKPass(data: pkpassData)
              if let vc = PKAddPassesViewController(pass: receivedPass) {
                // Here you can present the view controller
                self.present(vc, animated: true)
              }
        } catch {
        }
    }

    /// Called when there is an event with the current ad in the ad manager
    @objc func interactiveAdManager(_ adManager: AdManagerOwner, didReceiveAdEvent event: InteractiveAdEvent) {
        
        print("ad manager: \(adManager) triggered interactive ad event: \(event.stringEvent)")
        
        switch event.event {
        case .willBeSkipped:
            // Ad will be skipped as a result of an action during interactive ad
            break
        case .skipped:
           // Ad was skipped as a result of an action during interactive ad
           break
        case .extended:
           // Ad was extended with a new media as a result of an action
           break
        default:
            break
        }
    }
}
