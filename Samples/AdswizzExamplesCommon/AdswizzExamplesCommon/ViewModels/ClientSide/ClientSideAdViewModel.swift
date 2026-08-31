//
//  ClientSideAdViewModel.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK
import AVFoundation
import Combine

open class ClientSideAdViewModel: BaseAdViewModel {

    @Published public var playedTime: String = "00:00"

    public var adConnection: AdRequestConnection?
    public var externalPlayer: ExternalMediaPlayer?

    open var adServer: String { "demo.deliveryengine.adswizz.com" }
    open var zoneIds: [String] { [] }
    open var companionZones: String { "" }

    public func requestAds() {
        // Stop and clean current adManager instance
        adManager?.skipAd()
        adManager = nil

        // Cancel current connection if running
        adConnection?.cancel()

        do {
            let zones = try zoneIds.map { zoneId in
                try AdswizzAdZone.Builder()
                    .with(zoneId: zoneId)
                    .build()
            }

            let adRequest = try buildAdRequest(zones: zones)
            let connection = try AdRequestConnection(for: adRequest)
            adConnection = connection

            Task { [weak self] in
                guard let self else { return }
                do {
                    let adManager = try await connection.requestAds()

                    // Keep a strong ref to adManager
                    self.adManager = adManager
                    self.configureAdManager(adManager)

                    // Prepare
                    adManager.prepare()
                } catch {
                    print("Ad request connection failed to retrieve ads with error = \(error)")
                }

                // Cleanup
                self.adConnection = nil
            }
        } catch {
            print("Oops, the request is not valid: \(error)")
        }
    }

    open func buildAdRequest(zones: [AdswizzAdZone]) throws -> AdRequest {
        try AdswizzAdRequest.Builder()
            .with(server: adServer)
            .with(zones: zones)
            .with(companionZoneIds: companionZones.components(separatedBy: CharacterSet(charactersIn: ",")).compactMap { Int($0) })
            .build()
    }

    open func configureAdManager(_ adManager: AdManager?) {
        adManager?.delegate = self
        #if !os(tvOS)
        adManager?.interactiveDelegate = self
        #endif

        if useExternalPlayer, let player = externalPlayer {
            let settings = AdManagerSettings()
            settings.player = player
            adManager?.adManagerSettings = settings
        }
    }

    open func onAdEvent(_ event: AdEvent) {
        // Default: subclasses can override for additional behavior
    }

    open func pauseContent() {
        // Override in subclass
    }

    open func playContent() {
        // Override in subclass
    }

    #if !os(tvOS)
    open func onCouponReceived(_ pkpassData: Data) {
        // Override in subclass for coupon/PKPass handling
    }

    open func onInteractiveAdEvent(_ event: InteractiveAdEvent) {
        // Override in subclass for custom interactive ad event handling
    }
    #endif

    open func onPlayheadChanged(ad: AdData, playHead: TimeInterval, duration: TimeInterval) {
        // Override in subclass
    }

    public func stop() {
        adConnection?.cancel()
        adConnection = nil
        adManager?.reset()
        adManager?.delegate = nil
        #if !os(tvOS)
        adManager?.interactiveDelegate = nil
        #endif
        adManager = nil
        isPlaying = false
    }
}
