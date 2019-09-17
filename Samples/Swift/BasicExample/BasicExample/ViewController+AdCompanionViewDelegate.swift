//
//  ViewController+AdCompanionViewDelegate.swift
//  BasicExample
//
//  Created by Teodor Cristea on 17/09/2019.
//  Copyright © 2019 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AudioAdSDK

extension ViewController: AdCompanionViewDelegate {
    func adCompanionViewWillLoadAd(_ adCompanionView: AdCompanionView) {
        print("Received companion event: willLoadAd")
    }
    
    func adCompanionViewDidDisplayAd(_ adCompanionView: AdCompanionView) {
        print("Received companion event: didDisplayAd")
    }
    
    func adCompanionView(_ adCompanionView: AdCompanionView, didFailToDisplayAd error: Error) {
        print("Received companion error: didFailToDisplayAd")
    }
    
    func adCompanionViewOutOfContext(_ adCompanionView: AdCompanionView) {
        print("Received companion event: outOfContext")
    }
    
    func adCompanionView(_ adCompanionView: AdCompanionView, shouldOverrideCompanionClickThrough url: URL?) -> Bool {
        // Return true if you want to handle the click through URL yourself
        // e.g open it up with in-app Safari web view
        // By default it returns false and opens the URL in Safari app
        return false
    }
    
    func adCompanionViewWillLeaveApplication(_ adCompanionView: AdCompanionView) {
        print("Received companion event: willLeaveApp")
    }
    
}
