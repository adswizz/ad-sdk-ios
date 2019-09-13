//
//  ViewController.swift
//  Swift-sample
//
//  Created by Teodor Cristea on 13/09/2019.
//  Copyright © 2019 Inc, AdsWizz. All rights reserved.
//

import UIKit
import AudioAdSDK

class ViewController: UIViewController {
    var adManager: AdManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adswizz request ads
        do {
            let adRequest = try AdswizzAdRequest.Builder()
                .with(server: "demo.deliveryengine.adswizz.com")
                .with(playerId: "Acastiosplayer")
                .with(zoneId: "12561")
                .with(companionZones: "12562")
                .with(companionAdsEnabled: true)
                .build()
            let adRequestConnection = AdRequestConnection(for: adRequest)
            adRequestConnection.requestAds { adManager, error in
                if error == nil {
                    // Keep a strong ref to adManager
                    self.adManager = adManager
                    
                    // Prepare
                    adManager?.prepare()
                    
                    // Start playing ad(s)
                    adManager?.play()
                }
            }
        } catch {
            print("Failed to retrieve ads!!")
        }
    }
}

