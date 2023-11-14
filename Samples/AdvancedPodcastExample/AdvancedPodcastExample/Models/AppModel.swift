//
//  AppModel.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 29.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation
import AdswizzSDK

/// Notifies a listener about the `AppModel` playlist events
protocol AppModelListenerDelegate: AnyObject {
    //playlist
    func appModel(_ appModel: AppModelProtocol, stateWillChange state: Playlist.State, for podcast: PodcastConfig.Podcast)
    func appModel(_ appModel: AppModelProtocol, playheadChanged playhead: TimeInterval, duration: TimeInterval, for podcast: PodcastConfig.Podcast)
    func appModel(_ appModel: AppModelProtocol, didEncounterError error: Error, for podcast: PodcastConfig.Podcast)
    //ads
    func appModel(_ appModel: AppModelProtocol, didStartPlaying ad: AdData, withCompanion: Bool)
    func appModel(_ appModel: AppModelProtocol, didEndPlaying ad: AdData, withCompanion: Bool)
}

protocol AppModelListener {
    /// Register a listener to receive playlist events
    func add(listener: AppModelListenerDelegate)
    
    /// Unregister a listener from receiving playlist events
    func remove(listener: AppModelListenerDelegate)
}

protocol AppModelProtocol {
    func play(from podcast: PodcastConfig.Podcast)
    func playNext()
    func playPrevious()
    func pause()
    func resume()
    func seek(by time: TimeInterval, completion: @escaping () -> Void)
    func seek(to position: TimeInterval, completion: @escaping () -> Void)
    func stop()
}

/// The main app model
class AppModel {
    
    /// The listener model.
    private struct Listener {
        weak var item: AppModelListenerDelegate?
    }
    
    /// The list of registered listeners.
    private var listeners: [Listener] = []
    
    /// The specialized playlist that manages the list of podcasts.
    private let playlist: PodcastPlaylist
    
    /// The podcasts config.
    private let podcastConfig: PodcastConfig
    
    /// Returns the decoded podcasts array.
    var podcasts: [PodcastConfig.Podcast] {
        podcastConfig.podcasts
    }
    
    /// Returns `true` if the playlist is active (a podcast item is starting or it already started)
    var isPlaying: Bool {
        return playlist.isActive
    }
    
    /// Returns the active `(playing) podcast` configuration.
    var playingPodcast: PodcastConfig.Podcast? {
        return playlist.playingPodcast
    }
    
    /// Returns the current state of the playlist
    var currentState: Playlist.State {
        return playlist.state
    }
    
    /// Init.
    init() {
        podcastConfig = Bundle.main.decode(PodcastConfig.self, from: "config.json")
        playlist = PodcastPlaylist(from: podcastConfig)
        playlist.delegate = self
        playlist.adDelegate = self
    }
    
    /// Configure the model.
    func configure() {
        configureAnalytics()
        configureAdswizzSDK()
    }
}

extension AppModel: AppModelProtocol {
    /// Control the playlist.
    func play(from podcast: PodcastConfig.Podcast) {
        let currentIdx = podcasts.firstIndex(where: {podcast.id == $0.id})
        playlist.start(at: currentIdx ?? 0)
    }
        
    func playNext() {
        guard let next = playlist.next as? PodcastPlaylistItem else {
            return
        }
        play(from: next.podcastConfig)
    }
    
    func playPrevious() {
        guard let previous = playlist.previous as? PodcastPlaylistItem else {
            return
        }
        play(from: previous.podcastConfig)
    }
    
    func pause() {
        playlist.pause()
    }
    
    func resume() {
        playlist.resume()
    }
    
    func seek(by time: TimeInterval, completion: @escaping () -> Void) {
        playlist.seek(by: time, completion: completion)
    }
    
    func seek(to position: TimeInterval, completion: @escaping () -> Void) {
        playlist.seek(to: position, completion: completion)
    }

    func stop() {
        playlist.stop()
    }
}

extension AppModel: AppModelListener {
    func add(listener: AppModelListenerDelegate) {
        if listeners.first(where: { $0.item === listener }) != nil {
            return
        }
        listeners.append(Listener(item: listener))
    }
    
    func remove(listener: AppModelListenerDelegate) {
        if let idx = listeners.firstIndex(where: { $0.item === listener}) {
            listeners.remove(at: idx)
        }
    }
}

/// The app model responds to the playlist callbacks and handles related events
extension AppModel: PlaylistDelegate {
    
    /// The playlist is about to change its state
    func playlist(_ list: Playlist, stateWillChange state: Playlist.State) {
        Log.debug("playlist stateWillChange = \(state)")
    }
    
    /// An item within the playlist is about to change its state
    func playlist(_ list: Playlist, playlistItem listItem: PlaylistItem, stateWillChange state: Playlist.State) {
        Log.debug("playlistItem \(listItem) stateWillChange = \(state)")
        guard let item = listItem as? PodcastPlaylistItem else {
            return
        }
        let podcast = item.podcastConfig
        listeners.forEach {
            $0.item?.appModel(self, stateWillChange: state, for: podcast)
        }
    }
    
    /// The playlist received information about the playhead progress during playback
    func playlist(_ list: Playlist, playheadChanged playhead: TimeInterval, duration: TimeInterval) {
        Log.debug("playlist playheadChanged = \(playhead), duration = \(duration)")
        guard let podcast = playingPodcast else {
            return
        }
        listeners.forEach {
            $0.item?.appModel(self, playheadChanged: playhead, duration: duration, for: podcast)
        }
    }
    
    /// An item within the playlist encountered an error which reports it
    func playlist(_ list: Playlist, playlistItem listItem: PlaylistItem, didEncounterError error: Error) {
        Log.error(error)
        Log.debug("playlistItem \(listItem) didEncounterError = \(error)")
        guard let podcast = playingPodcast else {
            return
        }
        listeners.forEach {
            $0.item?.appModel(self, didEncounterError: error, for: podcast)
        }
    }
}

extension AppModel: PodcastPlaylistAdDelegate {
    func podcastPlaylist(_ playlist: PodcastPlaylist, didStartPlaying ad: AdData, withCompanion: Bool) {
        listeners.forEach {
            $0.item?.appModel(self, didStartPlaying: ad, withCompanion: withCompanion)
        }
    }
    
    func podcastPlaylist(_ playlist: PodcastPlaylist, didEndPlaying ad: AdData, withCompanion: Bool) {
        listeners.forEach {
            $0.item?.appModel(self, didEndPlaying: ad, withCompanion: withCompanion)
        }
    }
}

