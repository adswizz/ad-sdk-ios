//
//  Playlist+Podcasts.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 31.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation

extension Playlist {
    
    /// Create a playlist with podcast items from a config.
    convenience init(from data: PodcastConfig) {
        let items = data.podcasts.compactMap { try? PodcastPlaylistItem(with: $0) }
        self.init(items: items)
    }
}
