//
//  PodcastPlaylistItem.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 29.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation
import AVFoundation
import AdswizzSDK
import AdswizzExamplesCommon

/// Ad related events.
@MainActor protocol PodcastPlaylistItemAdDelegate: AnyObject {
    func podcastPlaylistItem(_ item: PodcastPlaylistItem, didStartPlaying ad: AdData, withCompanion: Bool)
    func podcastPlaylistItem(_ item: PodcastPlaylistItem, didEndPlaying ad: AdData, withCompanion: Bool)
}

class PodcastPlaylistItem: PlaylistItem, Isolatable {
    /// The `AdswizzSDK` manager for handling the monetized podcast.
    private let manager: AdswizzAdPodcastManager
    
    /// The player used for playing the podcast item. Conforms to the `MediaPlayerState` interface to satisfy the AdswizzSDK requirements.
    private let player = ExternalMediaPlayer()
    
    /// The `AdManager` received from `AdswizzSDK` for tracking all available ads in the podcast.
    weak private var adManager: AdManager?
    
    /// The podcast configuration.
    let podcastConfig: PodcastConfig.Podcast
    
    /// The internal delegate to communicate with the enclosing playlist.
    weak var adDelegate: PodcastPlaylistItemAdDelegate?
    
    /// Internal.
    private var pausedCalled = false
    private var stopping = false
    private var pendingSeekCompletion: (() -> Void)?
        
    /// `PlaylistItem` properties
    override var duration: TimeInterval {
        return player.currentDuration
    }
    
    override var currentPlayhead: TimeInterval {
        return player.currentPlayhead
    }

    /// Initialize the model.
    init(with podcast: PodcastConfig.Podcast) throws {
        manager = try AdswizzAdPodcastManager.Builder()
            .with(httpProtocol: .http)
            .with(adServer: "demo.deliveryengine.adswizz.com")
            .build()
        self.podcastConfig = podcast
        super.init()
        manager.delegate = self
        
        /// Setup the `AdswizzAdPodcastManager` to use the application's own player
        let settings = AdPodcastManagerSettings()
        settings.player = player
        manager.adPodcastManagerSettings = settings
    }
    
    override func start() {
        delegate?.playlistItemWillStart(self)
        
        guard let url = URL(string: podcastConfig.url) else {
            delegate?.playlistItem(self, didEncounterError: AppError.badURL)
            return
        }
        
        do {
            try manager.play(with: url)
        } catch {
            delegate?.playlistItem(self, didEncounterError: error)
        }
    }
    
    override func stop() {
        stopping = true
        /// Cleanup
        manager.stop()
        player.stop()
    }
    
    override func skip(with error: Error? = nil) {
        if player.playerStatus == .failed || player.playerStatus == .unknown {
            delegate?.playlistItemDidFinish(self)
        } else {
            manager.stop()
            player.stop()
        }
    }
    
    override func pause() {
        player.pause()
    }
    
    override func resume() {
        player.play()
    }
    
    override func seek(to position: TimeInterval, completion: @escaping () -> Void) {
        let seekTime = CMTime(value: Int64(position), timescale: 1)
        pendingSeekCompletion = completion
        player.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { [weak self] finished in
            if finished {
                //let the podcast manager know that the player finished the seek operation
                self?.onMainActor {
                    self?.pendingSeekCompletion?()
                    self?.pendingSeekCompletion = nil
                }
            }
        }
    }
    
    override func seek(by time: TimeInterval, completion: @escaping () -> Void) {
        let newPosition = currentPlayhead + time
        seek(to: newPosition, completion: completion)
    }
}

private extension PodcastPlaylistItem {
    func playerStatusChanged(_ newPlayerStatus: MediaPlayerStatus) {
        switch newPlayerStatus {
        case .initialized:
            break
        case .buffering, .bufferingFinished, .readyToPlay:
            break
        case .playing:
            couldBePlayed = true
            if pausedCalled {
                pausedCalled = false
                delegate?.playlistItemDidResume(self)
            } else {
                delegate?.playlistItemDidStart(self)
            }
        case .paused:
            pausedCalled = true
            delegate?.playlistItemDidPause(self)
        case .finished:
            if stopping {
                stopping = false
                delegate?.playlistItemDidStop(self)
            } else {
                delegate?.playlistItemDidFinish(self)
            }
        case .failed, .unknown:
            fallthrough
        @unknown default:
            couldBePlayed = false
            delegate?.playlistItem(self, didEncounterError: AppError.badPlayer)
        }
    }
    
    func playheadProgressChanged(_ time: TimeInterval) {
        if player.playerStatus != .playing && player.playerStatus != .bufferingFinished {
            return
        }
        delegate?.playlistItem(self, playheadChanged: time, duration: player.currentDuration)
    }
}

extension PodcastPlaylistItem: @MainActor AdPodcastManagerDelegate {
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, willStartPlaying url: URL) {
        /// When this method is called, `AdswizzAdPodcastManager` provides the **decorated** `url` with `AdswizzSDK` specific query params.
        /// Use the decorated `url` to play the podcast with your own player that must conform to `MediaPlayerState`.
        Log.debug("AdPodcastManager willStartPlaying url = \(url)")
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didFailPlaying url: URL, error: Error) {
        delegate?.playlistItem(self, didEncounterError: error)
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didReceive manager: AdManager) {
        /// Keep a weak reference to the `AdManager` for tracking ads lifecycle.
        adManager = manager
        adManager?.delegate = self
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, stateChanged state: MediaPlayerStatus) {
        playerStatusChanged(state)
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, playheadChanged playhead: TimeInterval, duration: TimeInterval) {
        playheadProgressChanged(playhead)
    }
    
    func adPodcastManagerPlayerShouldPause(_ adPodcastManager: AdPodcastManager) {
        player.pause()
    }
    
    func adPodcastManagerPlayerShouldResume(_ adPodcastManager: AdPodcastManager) {
        player.play()
    }
    
    func adPodcastManagerPlayer(_ adPodcastManager: AdPodcastManager, shouldSeekTo time: TimeInterval, completion: @escaping () -> Void) {
        seek(to: time, completion: completion)
    }
}
