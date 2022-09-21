//
//  Model.swift
//  BasicEmptyAdsExample
//
//  Created by Teodor Cristea on 20/01/2021.
//

import Foundation
import AdswizzSDK

protocol ModelDelegate: AnyObject {
    func model(_ model: Model, log line: String)
}

class Model {
    var adManager: AdManager?
    var adConnection: AdRequestConnection?
    // This zone should serve a VAST response with an <Error> tag for the opportunity URL and no ad to be played
    let zoneIds: [String] = ["14946"]
    let adServer: String = "demo.deliveryengine.adswizz.com"
    
    weak var delegate: ModelDelegate?
    
    func requestAds() throws {
        // Cancel current connection if running
        adConnection?.cancel()
        delegate?.model(self, log: "Requesting ads")
        
        // Adswizz request ads
        var zones: [AdswizzAdZone] = []
        func buildZone(for zoneId: String) throws {
            let zoneBuilder = AdswizzAdZone.Builder()
            let zone = try zoneBuilder
                .with(zoneId: zoneId)
                .build()
            zones.append(zone)
        }
        try zoneIds.forEach(buildZone)

        let adRequest = try AdswizzAdRequest.Builder()
            .with(httpProtocol: .http)
            .with(server: adServer)
            .with(zones: zones)
            .build()
        adConnection = try AdRequestConnection(for: adRequest)
        adConnection?.requestAds { [weak self] adManager, error in
            if let error = error {
                print("Ad request connection failed to retrieve ads with error = \(error)")
                if let sself = self {
                    sself.delegate?.model(sself, log: "Error: \(error.localizedDescription)")
                }
            } else {
                // Keep a strong ref to adManager
                self?.adManager = adManager
                adManager?.delegate = self
                
                if let sself = self {
                    sself.delegate?.model(sself, log: "Starting the adManager with adCount = \(adManager?.ads.count ?? 0)")
                }
                
                // Prepare
                adManager?.prepare()
                
                // Discard connection
                self?.adConnection = nil
            }
        }
    }
    func skip() {
        adManager?.skipAd()
    }
    
    func stop() {
        // Cancel current connection if running
        adConnection?.cancel()
        adConnection = nil

        // Stop Ad Manager
        adManager?.reset()
        adManager?.delegate = nil
        adManager = nil
    }
}

extension Model: AdManagerDelegate {
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        delegate?.model(self, log: "Received adManager error: \(error.localizedDescription)")
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }
    
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager: \(adManager) triggered ad event: \(event.stringEvent)")
        delegate?.model(self, log: "Received message \(event.stringEvent)")
                
        switch event.event {
        case .readyForPlay:
            // Ad manager finished loading current ad
            // At any point you can verify if the current ad is empty (non-playable).
            if let ad = event.ad, ad.isEmpty {
                print("ad manager: \(adManager) encountered an empty ad!")
                delegate?.model(self, log: "Detected empty ad!")
            }
            
            // Start playing ad(s). Even if the ad is empty and won't play anything,
            // make sure the error opportunity URL is fired by the SDK
            self.adManager?.play()
            
        case .didStartPlaying, .didFinishPlaying:
            print("These events won't be triggered for an empty ad")
            
        case .adCompleted:
            // Ad manager completed current ad
            break
            
        case .allAdsCompleted:
            // Ad manager just finished playing all ads
            break
            
        default:
            break
        }
    }
    
    func adManager(_ adManager: AdManager, ad: AdData, didChangedPlayHead playHead: TimeInterval, adDuration duration: TimeInterval) {
        print("ad manager:\(adManager) playhead changed: \(playHead), duration: \(duration)")
    }
}

