//
//  PodcastPlaylist.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 05.09.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation
import AdswizzSDK

/// Ad related events.
protocol PodcastPlaylistAdDelegate: AnyObject {
    func podcastPlaylist(_ playlist: PodcastPlaylist, didStartPlaying ad: AdData, withCompanion: Bool)
    func podcastPlaylist(_ playlist: PodcastPlaylist, didEndPlaying ad: AdData, withCompanion: Bool)
}

/// The `PodcastPlaylist` inherits the generic `Playlist` which provides functionality to play current, next or previous podcast item in the list.
class PodcastPlaylist: Playlist {
    /// The ad related delegate.
    weak var adDelegate: PodcastPlaylistAdDelegate?
    
    /// Returns `true` if the playlist is active or not (e.g playing)
    var isActive: Bool {
        return current != nil
    }
    
    /// Returns the active `(playing) podcast` configuration.
    var playingPodcast: PodcastConfig.Podcast? {
        return (current as? PodcastPlaylistItem)?.podcastConfig
    }
    
    override init(items: [PlaylistItem]) {
        super.init(items: items)
        let podcastItems: [PodcastPlaylistItem] = items.map { $0 as? PodcastPlaylistItem }.compactMap { $0 }
        podcastItems.forEach {
            $0.adDelegate = self
        }
    }
}

extension PodcastPlaylist: PodcastPlaylistItemAdDelegate {
    func podcastPlaylistItem(_ item: PodcastPlaylistItem, didStartPlaying ad: AdData, withCompanion: Bool) {
        adDelegate?.podcastPlaylist(self, didStartPlaying: ad, withCompanion: withCompanion)
    }
    
    func podcastPlaylistItem(_ item: PodcastPlaylistItem, didEndPlaying ad: AdData, withCompanion: Bool) {
        adDelegate?.podcastPlaylist(self, didEndPlaying: ad, withCompanion: withCompanion)
    }
}
