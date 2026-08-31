//
//  MainViewModel.swift
//  AdvancedPodcastExample
//
//  Created by George Mihoc on 20.01.2026.
//

import Foundation
import AdswizzSDK

@MainActor class MainViewModel: ObservableObject {
    @Published var podcasts: [PodcastConfig.Podcast] = []
    @Published var playingPodcast: PodcastConfig.Podcast?
    @Published var playerState: Playlist.State = .stopped
    @Published var minizimedPlayerVisible: Bool = false
    
    @Published var showingPlayer: Bool = false
    
    let model = AppModel()
    
    init() {
        self.podcasts = model.podcasts
        self.model.add(listener: self)
        updateState()
    }
    
    isolated deinit {
        model.remove(listener: self)
    }
    
    func play(podcast: PodcastConfig.Podcast) {
        if let playing = model.playingPodcast, playing.matches(podcast: podcast) {
    
        } else {
            model.play(from: podcast)
        }
    }
    
    func playNext() {
        model.playNext()
    }
    
    func playPrevious() {
        model.playPrevious()
    }
    
    func togglePlayPause() {
        if playerState == .started {
            model.pause()
        } else if playerState == .paused {
            model.resume()
        }
    }
    
    private func updateState() {
        playingPodcast = model.playingPodcast
        playerState = model.currentState
        minizimedPlayerVisible = model.isPlaying || model.currentState == .paused
    }
}

extension MainViewModel: AppModelListenerDelegate {
    func appModel(_ appModel: AppModelProtocol, stateWillChange state: Playlist.State, for podcast: PodcastConfig.Podcast) {
        playerState = state
        playingPodcast = (appModel as? AppModel)?.playingPodcast
        minizimedPlayerVisible = state != .stopped && state != .stopping
    }
    
    func appModel(_ appModel: AppModelProtocol, playheadChanged playhead: TimeInterval, duration: TimeInterval, for podcast: PodcastConfig.Podcast) {}
    
    func appModel(_ appModel: AppModelProtocol, didEncounterError error: Error, for podcast: PodcastConfig.Podcast) {}
    
    func appModel(_ appModel: AppModelProtocol, didStartPlaying ad: AdData, withCompanion: Bool) {}
    
    func appModel(_ appModel: AppModelProtocol, didEndPlaying ad: AdData, withCompanion: Bool) {}
}
