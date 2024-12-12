//
//  ClientSideModelView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 18.11.2024.
//

import Foundation
import AdswizzSDK

class ClientSideModelView: ObservableObject {
    private var adManager: AdManager?
    private var adConnection: AdRequestConnection?
    private let adServer = "demo.deliveryengine.adswizz.com"
    private let zoneIds: [String]
    var videoView: AdVideoView? = nil
    @Published var isPlaying: Bool = false
    @Published var adType: AdType?
    
    init(zoneIds: [String]) {
        self.zoneIds = zoneIds
    }
    
    func requestAds() {
        //stop and clean current adManager instance
        adManager?.skipAd()
        adManager = nil
        
        // Cancel current connection if running
        adConnection?.cancel()
        
        // Adswizz request ads
        do {
            let zoneBuilder = AdswizzAdZone.Builder()
            let zones = try zoneIds.compactMap {
                try zoneBuilder
                    .with(zoneId: $0)
                    .build()
            }
            
            let adRequest = try videoAdRequest(zones: zones)
            
            adConnection = try AdRequestConnection(for: adRequest)
            adConnection?.requestAds { [weak self] adManager, error in
                if let error {
                    print("Ad request connection failed to retrieve ads with error = \(error)")
                } else {
                    // Keep a strong ref to adManager
                    self?.adManager = adManager
                    adManager?.delegate = self
                    
                    if let self, let adManager {
                        // create the video view for the Ad break
                        self.videoView = AdVideoView()
                        
                        // Pass the video view
                        let settings = AdManagerSettings()
                        settings.videoView = self.videoView
                        adManager.adManagerSettings = settings
                    }
                    
                    // Prepare
                    adManager?.prepare()
                    
                    // Cleanup
                    self?.adConnection = nil
                }
            }
        } catch {
            print("Oops, the request is not valid")
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
    
    private func videoAdRequest(zones: [AdswizzAdZone]) throws -> AdRequest {
        try AdswizzAdRequest.Builder()
            .with(httpProtocol: .http)
            .with(server: adServer)
            .with(zones: zones)
            .build()
    }
}

extension ClientSideModelView: AdManagerDelegate {
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }
    
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager: \(adManager) triggered ad event: \(event.stringEvent)")
        switch event.event {
        case .readyForPlay:
            adType = event.ad?.adType
            // Start playing ad(s)
            adManager.play()
        case .didStartPlaying:
            isPlaying = true
        case .allAdsCompleted:
            // Cleanup
            self.adManager = nil
            isPlaying = false
            videoView = nil
        default:
            break
        }
    }
}
