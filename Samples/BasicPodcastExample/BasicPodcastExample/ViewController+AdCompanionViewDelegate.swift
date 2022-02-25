//
//  ViewController+AdCompanionViewDelegate.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 15.02.2022.
//

import Foundation
import AdswizzSDK

extension ViewController: AdCompanionViewDelegate {
    func adCompanionViewWillLoad(_ adCompanionView: AdCompanionView) {
        print("Received companion event: willLoadAd")
    }
    
    func adCompanionViewDidDisplay(_ adCompanionView: AdCompanionView) {
        print("Received companion event: didDisplayAd")
    }
    
    func adCompanionView(_ adCompanionView: AdCompanionView, didFailToDisplay error: Error) {
        print("Received companion error: didFailToDisplayAd")
    }
    
    func adCompanionViewDidEndDisplay(_ adCompanionView: AdCompanionView) {
        print("Received companion event: didEndDisplay")
    }
    
    func adCompanionView(_ adCompanionView: AdCompanionView, shouldOverrideCompanionClickThrough url: URL) -> Bool {
        // Return true if you want to handle the click through URL yourself
        // e.g open it up with in-app Safari web view
        // By default it returns false which signals the SDK to handle it internally
        // As a result it will exit the app and open the URL in default Safari app
        return false
    }
    
    func adCompanionViewWillLeaveApplication(_ adCompanionView: AdCompanionView) {
        print("Received companion event: willLeaveApp")
    }
    
}
