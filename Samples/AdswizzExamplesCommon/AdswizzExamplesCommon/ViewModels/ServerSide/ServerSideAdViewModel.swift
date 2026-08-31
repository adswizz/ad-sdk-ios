//
//  ServerSideAdViewModel.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK
import AVFoundation
import Combine

open class ServerSideAdViewModel: BaseAdViewModel {

    public var streamManager: AdswizzAdStreamManager?
    public var adBreakManager: AdManager?
    public var externalPlayer: ExternalMediaPlayer?
    @Published public var dvrMetadata: AdStreamDVRMetadata?

    open var adServer: String { "demo.deliveryengine.adswizz.com" }
    open var streamUrl: URL? { nil }
    open var companionZones: String { "" }
    open var streamCapabilities: [AdStreamCapability] { [] }

    public func play() {
        do {
            try preparePlay()
            guard let url = streamUrl else {
                print("No stream URL configured")
                return
            }
            try streamManager?.play(with: url)
            isPlaying = true
            isPaused = false
            externalPlayerSwitchEnabled = false
            status = "Playing stream..."
        } catch {
            print("Failed to play ad stream. Reason = \(error)")
            status = "Error: \(error.localizedDescription)"
        }
    }

    public func playFromTimestamp(_ timestamp: NSNumber) throws {
        try preparePlay()
        guard let url = streamUrl else {
            print("No stream URL configured")
            return
        }
        try streamManager?.play(with: url, timestamp: timestamp)
        isPlaying = true
        isPaused = false
        externalPlayerSwitchEnabled = false
        status = "Playing from timestamp..."
    }

    public func stop() {
        if useExternalPlayer {
            externalPlayer?.stop()
        } else {
            streamManager?.stop()
        }

        streamManager?.delegate = nil
        streamManager = nil
        isPlaying = false
        isPaused = false
        externalPlayerSwitchEnabled = true
        status = "Stream stopped"
    }

    public func pause() {
        if useExternalPlayer {
            externalPlayer?.pause()
        } else {
            streamManager?.pause()
        }
        isPaused = true
        status = "Stream paused"
    }

    public func resume() {
        if useExternalPlayer {
            externalPlayer?.play()
        } else {
            streamManager?.resume()
        }
        isPaused = false
        status = "Playing stream..."
    }

    public func skipCurrentAd() {
        adBreakManager?.skipAd()
    }

    open func onAdBreakStarted(manager: AdManager) {
        adBreakManager = manager
        adBreakManager?.delegate = self // register for notification on this AdManager
        #if !os(tvOS)
        adBreakManager?.interactiveDelegate = self // register for interactive ads notifications
        #endif
        showSkipAd = true
        status = "Ad break detected! Playing ad(s)..."
    }

    open func onAdBreakEnded() {
        adBreakManager?.delegate = nil
        #if !os(tvOS)
        adBreakManager?.interactiveDelegate = nil
        #endif
        adBreakManager = nil
        showSkipAd = false
        status = "Playing stream..."
    }

    open func onAdEvent(_ event: AdEvent) {
        // Override in subclass for custom ad event handling
    }

    #if !os(tvOS)
    open func onCouponReceived(_ pkpassData: Data) {
        // Override in subclass for coupon/PKPass handling
    }

    open func onInteractiveAdEvent(_ event: InteractiveAdEvent) {
        // Override in subclass for custom interactive ad event handling
    }
    #endif

    private func preparePlay() throws {
        if streamManager == nil {
            streamManager = try AdswizzAdStreamManager.Builder()
                .with(adServer: adServer)
                .with(httpProtocol: .https)
                .with(companionZones: companionZones)
                .build()
            streamManager?.delegate = self
        }

        let settings = AdStreamManagerSettings()
        if useExternalPlayer, let player = externalPlayer {
            settings.player = player
        }
        streamCapabilities.forEach { settings.addCapability($0) }
        streamManager?.adStreamManagerSettings = settings
    }
}
