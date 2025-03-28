//
//  Model.swift
//  BasicVideoAdExample
//
//  Created by Teodor Cristea on 16/11/2020.
//

import Foundation
import AdswizzSDK

enum SkipState {
    case initial
    case inactive(value: String)
    case active
}

protocol ModelAdDelegate: AnyObject {
    // loading ads
    func model(_ model: Model, didStartLoading adType: AdType)
    // playback ads
    func model(_ model: Model, didStartPlayback adType: AdType)
    func model(_ model: Model, didEndPlayback adType: AdType)
    func model(_ model: Model, didComplete adType: AdType)
    func modelDidCompleteAllAds(_ model: Model)
    // playhead
    func model(_ model: Model, playHeadChanged playHead: TimeInterval, duration: TimeInterval)
    // skippable ads
    func model(_ model: Model, skipStateChanged state: SkipState)
    // ad count progression
    func model(_ model: Model, adIndexChanged index: Int)
}

protocol ModelAdDatasource: AnyObject {
    func modelAdVideoViewProvider(_ model: Model) -> AdVideoView
}

protocol ModelAdExternalPlayer: AnyObject {
    func shouldUseExternalPlayer(_ model: Model) -> Bool
    func disableInteractionPlayer(_ value: Bool)
}

class Model {
    var adManager: AdManager?
    var adConnection: AdRequestConnection?
    var externalPlayer = ExternalMediaPlayer()
    // These 2 zones should serve one video ad and one audio ad
    let zoneIds: [String] = ["19984", "17862"]
    let adServer: String = "demo.deliveryengine.adswizz.com"
    // Let's mock the skippOffset for an ad. Normally this value would be part of the AdData for an ad.
    let skipOffset: NSNumber = NSNumber(floatLiteral: 5)
    var currentAdIndex = 0 {
        didSet {
            adDelegate?.model(self, adIndexChanged: currentAdIndex)
        }
    }
    
    weak var adDatasource: ModelAdDatasource?
    weak var adDelegate: ModelAdDelegate?
    weak var externalPlayerDelegate: ModelAdExternalPlayer?
    
    var adCountText: String {
        return "\(currentAdIndex)/\(adManager?.adCount ?? 0) ads"
    }

    var totalAdsDurationText: String {
        return "totalAdsDuration: \(adManager?.totalAdsDuration ?? 0) seconds"
    }

    var shouldUseExternalPlayer: Bool {
        return externalPlayerDelegate?.shouldUseExternalPlayer(self) == true
    }
    
    func requestAds() throws {
        // Cancel current connection if running
        adConnection?.cancel()
        
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
            } else {
                // Pass the video view
                let settings = AdManagerSettings()
                if let sself = self {
                    let videoView = sself.adDatasource?.modelAdVideoViewProvider(sself)
                    videoView?.delegate = self // Optional
                    settings.videoView = videoView
                }
                
                // Keep a strong ref to adManager
                self?.adManager = adManager
                adManager?.delegate = self
                
                if self?.shouldUseExternalPlayer == true {
                    settings.player = self?.externalPlayer
                }

                adManager?.adManagerSettings = settings
                
                // Prepare
                adManager?.prepare()
                
                // Cleanup
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

extension AdManager {
    /// The current number of playbable ads
    var adCount: Int {
        return ads.count
    }

    /// The total number of seconds for all playable ads
    var totalAdsDuration: TimeInterval {
        return ads.compactMap { $0.duration }.reduce(0, +)
    }
}
