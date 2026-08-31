//
//  Playlist.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 29.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation

/// The `PlaylistDelegate` informs other interested objects in the playlist various events and updates.
@MainActor protocol PlaylistDelegate: AnyObject {
    func playlist(_ list: Playlist, stateWillChange state: Playlist.State)
    func playlist(_ list: Playlist, playlistItem listItem: PlaylistItem, stateWillChange state: Playlist.State)
    func playlist(_ list: Playlist, playheadChanged playhead: TimeInterval, duration: TimeInterval)
    func playlist(_ list: Playlist, playlistItem listItem: PlaylistItem, didEncounterError error: Error)
}

/// A playlist implementation which manages a list of `PlaylistItem`.
/// The playlist encapsulates functionality such as start, stop and playback related logic.
@MainActor class Playlist {
    
    /// The state of the playlist.
    enum State: String {
        case starting
        case started
        case paused
        case stopping
        case stopped
    }
    
    /// Internal.
    private var items = [PlaylistItem]()
    private(set) var current: PlaylistItem?
    private var startIndex = 0
    
    /// Indicates whether the playlist is looping the items or not.
    /// By default, when the playlist reaches and finishes playing the last item, it starts playing items from the beginning.
    var loop = true

    /// The `PlaylistDelegate` which informs its delegate.
    weak var delegate: PlaylistDelegate?
    private(set) var state = State.stopped {
        willSet {
            if newValue != state {
                delegate?.playlist(self, stateWillChange: newValue)
            }
        }
    }
    
    /// Access the next playlist item.
    /// When `looping` is enabled and the playlist index is currently positioned on the last item,  it will return the first item.
    var next: PlaylistItem? {
        guard let current = current, let currentIdx = items.firstIndex(where: {current === $0}) else {
            return items[startIndex]
        }
        let nextIndex = items.index(after: currentIdx)
        if nextIndex == items.endIndex {
            return loop ? items.first : nil
        }
        return items[nextIndex]
    }
    
    /// Access the previous playlist item.
    /// When `looping` is enabled and the playlist index is currently positioned on the first item,  it will return the last item.
    var previous: PlaylistItem? {
        guard let current = current, let currentIdx = items.firstIndex(where: {current === $0}) else {
            return items.first
        }
        if currentIdx == items.startIndex {
            return loop ? items.last : nil
        }
        let previousIndex = items.index(before: currentIdx)
        return items[previousIndex]
    }
    
    /// Initialize the playlist with a list of items.
    init(items: [PlaylistItem]) {
        self.items = items
        items.forEach { $0.delegate = self }
    }
    
    /// Resume playlist if it's currently `.paused`
    func resume() {
        if state != .paused {
            return
        }
        current?.resume()
    }
    
    /// Pause playlist if it already `.started`
    func pause() {
        if state != .started {
            return
        }
        current?.pause()
    }
    
    /// Start the playlist by playing the first item
    func start(at index: Int = 0) {
        startIndex = index
        stop()
        items.forEach { $0.couldBePlayed = true }
        current = next
        state = .starting
        current?.start()
    }
    
    /// Stop the playlist
    func stop() {
        state = .stopping
        current?.stop()
        current = nil
    }
    
    /// Skip the current playlist item with an optional `error`
    func skip(with error: Error? = nil) {
        current?.skip(with: error)
    }
    
    /// Seek the content from the current playlist item by  `time` seconds
    func seek(by time: TimeInterval, completion: @escaping () -> Void) {
        current?.seek(by: time, completion: completion)
    }
    
    /// Seek the content from the current playlist item to a new `position` in time
    func seek(to position: TimeInterval = 0, completion: @escaping () -> Void) {
        current?.seek(to: position, completion: completion)
    }
}

/// Handle `PlaylistItemDelegate` from the playlist items
extension Playlist: PlaylistItemDelegate {
    func playlistItem(_ item: PlaylistItem, playheadChanged playhead: TimeInterval, duration: TimeInterval) {
        delegate?.playlist(self, playheadChanged: playhead, duration: duration)
    }
    
    func playlistItem(_ item: PlaylistItem, didEncounterError error: Error) {
        delegate?.playlist(self, playlistItem: item, didEncounterError: error)
        if items.filter( { $0.couldBePlayed }).count == 0 {
            stop()
            return
        }
        if item === current {
            skip()
        }
    }
    
    func playlistItemWillStart(_ item: PlaylistItem) {
        if item !== current {
            return
        }
        delegate?.playlist(self, playlistItem: item, stateWillChange: .starting)
    }
    
    func playlistItemDidStart(_ item: PlaylistItem) {
        if item !== current {
            return
        }
        state = .started
        delegate?.playlist(self, playlistItem: item, stateWillChange: .started)
    }
    
    func playlistItemDidStop(_ item: PlaylistItem) {
        if item !== current {
            return
        }
        delegate?.playlist(self, playlistItem: item, stateWillChange: .stopped)
        state = .stopped
    }
    
    func playlistItemDidPause(_ item: PlaylistItem) {
        if item !== current {
            return
        }
        delegate?.playlist(self, playlistItem: item, stateWillChange: .paused)
        state = .paused
    }
    
    func playlistItemDidResume(_ item: PlaylistItem) {
        item.couldBePlayed = true
        if item !== current {
            return
        }
        delegate?.playlist(self, playlistItem: item, stateWillChange: .started)
        state = .started
    }
    
    func skipIfNeeded(_ item: PlaylistItem) {
        current = next
        current?.start()
        
        delegate?.playlist(self, playlistItem: item, stateWillChange: .stopped)
        if next != nil {
            current = next
            current?.start()
        }
    }
    
    func playlistItemDidFinish(_ item: PlaylistItem) {
        if item.skipIfNeeded {
            skipIfNeeded(item)
            return
        }
        if item !== current {
            return
        }
        delegate?.playlist(self, playlistItem: item, stateWillChange: .stopped)
        if state == .started || state == .paused {
            current = next
            current?.start()
        }
    }
}
