//
//  PlayerViewModel.swift
//  AdvancedPodcastExample
//
//  Created by George Mihoc on 20.01.2026.
//

import Foundation
import AdswizzSDK

@MainActor class PlayerViewModel: ObservableObject {
    @Published var podcast: PodcastConfig.Podcast?
    @Published var isPlaying: Bool = false
    @Published var duration: TimeInterval = 0
    @Published var playhead: TimeInterval = 0
    @Published var showCompanion: Bool = false
    private let model: AppModel
    
    init(podcast: PodcastConfig.Podcast?, model: AppModel) {
        self.podcast = podcast
        self.model = model
        self.model.add(listener: self)
        
        if let podcast = podcast, let playingPodcast = model.playingPodcast, podcast.matches(podcast: playingPodcast) {
             isPlaying = model.isPlaying || model.currentState == .started
             showCompanion = false 
        }
    }
    
    isolated deinit {
        model.remove(listener: self)
    }
    
    func play() {
        if isPlaying {
            model.pause()
        } else {
            if model.currentState == .paused {
                model.resume()
            } else if let podcast {
                model.play(from: podcast)
            }
        }
    }
    
    func seek(to value: Float) {
        let time = TimeInterval(value) * duration
        model.seek(to: time) {}
    }
    
    func seekForward() {
        model.seek(by: 10) {}
    }
    
    func seekBackward() {
        model.seek(by: -10) {}
    }
}

extension PlayerViewModel: AppModelListenerDelegate {
    func appModel(_ appModel: AppModelProtocol, stateWillChange state: Playlist.State, for podcast: PodcastConfig.Podcast) {
        guard let current = self.podcast, current.matches(podcast: podcast) else { return }
        
        switch state {
        case .started:
            isPlaying = true
        case .paused, .stopped, .stopping:
            isPlaying = false
        default:
            break
        }
    }
    
    func appModel(_ appModel: AppModelProtocol, playheadChanged playhead: TimeInterval, duration: TimeInterval, for podcast: PodcastConfig.Podcast) {
        guard let current = self.podcast, current.matches(podcast: podcast) else { return }
        self.playhead = playhead
        self.duration = duration
    }
    
    func appModel(_ appModel: AppModelProtocol, didEncounterError error: Error, for podcast: PodcastConfig.Podcast) {}
    
    func appModel(_ appModel: AppModelProtocol, didStartPlaying ad: AdData, withCompanion: Bool) {
        guard let playing = model.playingPodcast, let current = self.podcast, playing.matches(podcast: current) else { return }
        
        if withCompanion {
            showCompanion = true
        }
    }
    
    func appModel(_ appModel: AppModelProtocol, didEndPlaying ad: AdData, withCompanion: Bool) {
        showCompanion = false
    }
}
