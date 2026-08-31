//
//  ServerSideAdViewModel+InteractiveAdManagerDelegate.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

#if !os(tvOS)
import AdswizzSDK

extension ServerSideAdViewModel: InteractiveAdManagerDelegate {
    /// This callback is triggered immediately after the coupon was downloaded (the download of the coupon may be triggered by a shake event).
    /// Give the host application a chance to take over the control for presenting coupons
    /// This callback is always triggered on the main thread.
    public func interactiveAdManager(_ adManager: AdManagerOwner, shouldPresentCoupon pkpassData: Data) {
        onCouponReceived(pkpassData)
    }

    /// Called when there is an event with the current ad in the ad manager
    public func interactiveAdManager(_ adManager: AdManagerOwner, didReceiveAdEvent event: InteractiveAdEvent) {
        print("ad manager: \(adManager) triggered interactive ad event: \(event.stringEvent)")
        onInteractiveAdEvent(event)
    }
}
#endif
