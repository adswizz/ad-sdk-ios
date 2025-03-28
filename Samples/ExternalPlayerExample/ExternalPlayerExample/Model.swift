//
//  Model.swift
//  ExternalPlayerExample
//
//  Created by Bogdan Cosescu on 20/04/2020.
//  Copyright © 2020 Adswizz. All rights reserved.
//

import Foundation
import AdswizzSDK

class Model {
    let adServer = "demo.deliveryengine.adswizz.com"
    let zoneId = "17862"

    private var adManager: AdManager?
    private var adConnection: AdRequestConnection?
    private var player = ExternalMediaPlayer()
    weak var delegate: ModelDelegate?

    
    func requestAds() {
        adConnection?.cancel()
        
        delegate?.model(self, log: "Requesting ads")
        do {
            let zoneBuilder = AdswizzAdZone.Builder()
            let zone = try zoneBuilder
                .with(zoneId: zoneId)
                .build()

            let adRequest = try AdswizzAdRequest.Builder()
                .with(server: adServer)
                .with(zones: [zone])
                .build()
            adConnection = try AdRequestConnection(for: adRequest)
            adConnection?.requestAds { [weak self] adManager, error in
                self?.requestAdsHandler(adManager, error)
            }
        } catch {
            delegate?.model(self, log: "No valid request")
            kLog.log("Oops, the request is not valid")
        }
    }
}

private extension Model {
    func requestAdsHandler(_ adManager: AdManager?, _ error: Error?) {
        guard let adManager = adManager else {
            if let error = error {
                delegate?.model(self, log: "Error: \(error.localizedDescription)")
                kLog.log("Ad request connection failed to retrieve ads with error = \(error)")
            }
            return
        }
        // Keep a strong ref to adManager
        self.adManager = adManager
        adManager.delegate = self
        
        //inform AdManager we are playing the ads
        let settings = AdManagerSettings()
        settings.player = player
        adManager.adManagerSettings = settings
        
        delegate?.model(self, log: "Starting the adManager")

        // Prepare
        adManager.prepare()
        
        // Cleanup
        adConnection = nil
    }
}

extension Model: AdManagerDelegate {
    
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        kLog.log("AdManager triggered ad event: \(event.stringEvent)")
        delegate?.model(self, log: "Received message \(event.stringEvent)")
        
        switch event.event {
        case .preparingForPlay:
            guard let adMedia = event.ad?.asset.mediaUrl else {
                adManager.skipAd()
                return
            }
            
            //let's mock the duration as we don't have it in out player
            player.play(adMedia, duration: 6.0)
            
        case .allAdsCompleted:
            // Cleanup
            self.adManager = nil
            
        default:
            break
        }
    }
    
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        delegate?.model(self, log: "Received adManager error: \(error.localizedDescription)")
        kLog.log("AdManager triggered error: \(error.localizedDescription)")
    }
}

protocol ModelDelegate: class {
    func model(_ model: Model, log line: String)
}
