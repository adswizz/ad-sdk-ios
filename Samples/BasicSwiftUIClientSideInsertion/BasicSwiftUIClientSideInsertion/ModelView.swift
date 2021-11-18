//
//  ModelView.swift
//  BasicDVRRequestExample
//
//  Created by Adrian Manolache on 09.11.2021.
//

import Foundation
import AdswizzSDK

enum AdType {
    case banner
    case video
}

class ModelView: ObservableObject {
    private var adManager: AdManager?
    private var adConnection: AdRequestConnection?
    private let adServer = "demo.deliveryengine.adswizz.com"
    private let zoneIds: [String]
    private let companionZone: String?
    private let adType: AdType
    private var adManagerDelegate: AdManagerDelegate?
    var videoView: AdVideoView?
    @Published var isPlaying: Bool
    
    init(adType: AdType, zoneIds: [String], companionZone: String? = nil) {
        self.adType = adType
        self.zoneIds = zoneIds
        self.companionZone = companionZone
        self.isPlaying = false
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
                .build() }
            
            let adRequest = adType == .banner ? try bannerAdRequest(zones: zones, companionZone: companionZone) : try videoAdRequest(zones: zones)
        
            adConnection = try AdRequestConnection(for: adRequest)
            adConnection?.requestAds { [weak self] adManager, error in
                if let error = error {
                    print("Ad request connection failed to retrieve ads with error = \(error)")
                } else {
                    // Keep a strong ref to adManager
                    self?.adManager = adManager
                    adManager?.delegate = self
                    
                    if self?.adType == .video {
                        // Pass the video view
                        let settings = AdManagerSettings()
                        if let videoView = self?.videoView {
                            settings.videoView = videoView
                        }
                        // Keep a strong ref to adManager
                        self?.adManager = adManager
                        adManager?.delegate = self
                        adManager?.adManagerSettings = settings
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
    
    private func bannerAdRequest(zones: [AdswizzAdZone], companionZone: String?) throws -> AdRequest {
        var builder = AdswizzAdRequest.Builder()
            .with(server: adServer)
            .with(zones: zones)
        if let companionZone = companionZone {
            builder = builder.with(companionZones: companionZone)
        }
        return try builder.build()
    }
 
    private func videoAdRequest(zones: [AdswizzAdZone]) throws -> AdRequest {
        try AdswizzAdRequest.Builder()
            .with(httpProtocol: .http)
            .with(server: adServer)
            .with(zones: zones)
            .build()
    }
}

extension ModelView: AdManagerDelegate {
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("ad manager: \(adManager) received ad: \(ad?.id ?? "unknown")")
    }
    
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        print("ad manager: \(adManager) triggered ad event: \(event.stringEvent)")
        switch event.event {
        case .readyForPlay:
            isPlaying = true
            // Start playing ad(s)
            self.adManager?.play()

        case .allAdsCompleted:
            // Cleanup
            self.adManager = nil
            isPlaying = false
        default:
            break
        }
        adManagerDelegate?.adManager(adManager, didReceiveAdEvent: event)
    }
}
