//
//  PlaylistItem.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 29.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation

/// The `PlaylistItemDelegate` informs a playlist.
protocol PlaylistItemDelegate: AnyObject {
    func playlistItemWillStart(_ item: PlaylistItem)
    func playlistItemDidStart(_ item: PlaylistItem)
    func playlistItemDidStop(_ item: PlaylistItem)
    func playlistItemDidPause(_ item: PlaylistItem)
    func playlistItemDidResume(_ item: PlaylistItem)
    func playlistItemDidFinish(_ item: PlaylistItem)
    func playlistItem(_ item: PlaylistItem, playheadChanged playhead: TimeInterval, duration: TimeInterval)
    func playlistItem(_ item: PlaylistItem, didEncounterError error: Error)
}

/// A playlist item base implementation.
/// The item encapsulates functionality such as start, stop and playback related logic.
class PlaylistItem: NSObject {
    
    /// Internal.
    var couldBePlayed = true
    var skipIfNeeded = false
    
    /// The duration reported by the item.
    private(set) var duration: TimeInterval = 0
    
    /// The current progress for playhead.
    private(set) var currentPlayhead: TimeInterval = 0
    
    /// The `PlaylistItemDelegate`. Typically this is a `Playlist` object.
    weak var delegate: PlaylistItemDelegate?
    
    /// Starts the item. Overridable.
    /// Subclasses should call `super` in their implementation.
    func start() {
        delegate?.playlistItemDidStart(self)
    }
    
    /// Stops the item. Overridable.
    /// Subclasses should call `super` in their implementation.
    func stop() {
        delegate?.playlistItemDidStop(self)
    }
    
    /// Resume the item. Overridable.
    /// Subclasses should call `super` in their implementation.
    func resume() {
        delegate?.playlistItemDidResume(self)
    }
    
    /// Pause the item. Overridable.
    /// Subclasses should call `super` in their implementation.
    func pause() {
        delegate?.playlistItemDidPause(self)
    }
    
    /// Skip the item with an optional `error`. Overridable.
    func skip(with error: Error? = nil) {
    }
    
    /// Seek within an item content to a new `position`. Overridable.
    func seek(to position: TimeInterval, completion: @escaping () -> Void) {
    }
    
    /// Seek the content from the playlist item by  `time` seconds
    func seek(by time: TimeInterval, completion: @escaping () -> Void) {
    }
}
