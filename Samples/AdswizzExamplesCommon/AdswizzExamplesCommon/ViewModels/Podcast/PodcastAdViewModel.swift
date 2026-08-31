//
//  PodcastAdViewModel.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK
import SwiftUI
import Combine

open class PodcastAdViewModel: BaseAdViewModel {

    @Published public var currentTime: TimeInterval = 0
    @Published public var totalDuration: TimeInterval = 0

    public var podcastManager: AdswizzAdPodcastManager?
    public var adBreakManager: AdManager?

    open var adServer: String { "demo.deliveryengine.adswizz.com" }
    open var httpProtocol: HTTPProtocol { .http }
    open var companionZones: String { "" }

    public func configurePodcastManager() throws {
        podcastManager = try AdswizzAdPodcastManager.Builder()
            .with(adServer: adServer)
            .with(httpProtocol: httpProtocol)
            .with(companionZones: companionZones) // optional, if no companion zone id is found in the vast file this id will be used instead
            .build()
        podcastManager?.delegate = self
    }

    open func play(url: URL, shouldUseCustomPlayer: Bool = false) {
        do {
            if podcastManager == nil {
                try configurePodcastManager()
            }

            if shouldUseCustomPlayer {
                let settings = AdPodcastManagerSettings()
                podcastManager?.adPodcastManagerSettings = settings
            }

            try podcastManager?.play(with: url)
            isPlaying = true
            isPaused = false
        } catch {
            print("Failed to play podcast: \(error)")
        }
    }

    public func stop() {
        podcastManager?.stop()
        isPlaying = false
        isPaused = false
        currentTime = 0
    }

    public func pause() {
        podcastManager?.pause()
        isPaused = true
    }

    public func resume() {
        podcastManager?.resume()
        isPaused = false
    }

    public func skipCurrentAd() {
        adBreakManager?.skipAd()
    }

    open func onAdBreakReceived(manager: AdManager) {
        adBreakManager = manager
        adBreakManager?.delegate = self
    }

    open func onPlayheadChanged(playhead: TimeInterval, duration: TimeInterval) {
        currentTime = playhead
        totalDuration = duration
    }

    open func onAdEvent(_ event: AdEvent) {
        // Override in subclass for custom ad event handling
    }

    open func onWillStartPlaying(url: URL) {
        // Override in subclass if using external player
    }

    open func onPodcastPlayerShouldPause() {
        // Override in subclass if using external player
    }

    open func onPodcastPlayerShouldResume() {
        // Override in subclass if using external player
    }

    open func onPodcastPlayerShouldSeek(to time: TimeInterval, completion: @escaping @Sendable () -> Void) {
        // Override in subclass if using external player
        completion()
    }
}
