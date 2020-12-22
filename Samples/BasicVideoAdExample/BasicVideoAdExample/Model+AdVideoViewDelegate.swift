//
//  Model+AdVideoViewDelegate.swift
//  BasicVideoAdExample
//
//  Created by Teodor Cristea on 16/11/2020.
//

import Foundation
import AdswizzSDK

extension Model: AdVideoViewDelegate {
    
    // Called immediately when a touch event is detected over the video view.
    // Gives your app a chance to override the default behaviour when a `clickThrough` event occurs.
    func adVideoView(_ adVideoView: AdVideoView, shouldOverrideVideoClickThrough url: URL) -> Bool {
        // If you return `true` it is your responsability to handle `clickThrough`
        // e.g by openening the target URL in an in-app or external browser (e.g Safari).
        
        // Returning `false` lets AdswizzSDK handle it by leaving the app and open Safari.
        return false
    }

    // Called when the application is about to transition to background state as a result of
    // a `clickThrough` event and the targetURL is opened in the external browser.
    func adVideoViewWillLeaveApplication(_ adVideoView: AdVideoView) {
        // Called only if you return `false` in `adVideoView(:shouldOverrideVideoClickThrough:) -> Bool`
    }
}
