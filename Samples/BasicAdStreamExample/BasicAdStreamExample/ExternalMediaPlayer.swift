//
//  ExternalPlayer.swift
//  BasicAdStreamExample
//
//  Created by Adrian Manolache on 29.03.2022.
//  Copyright © 2022 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzSDK
import AVKit

/// `AVPlayer` subclass which adopts the `MediaPlayerState` protocol
class ExternalMediaPlayer: AVPlayer, MediaPlayerState {
    
    var observingCurrentItem = false
    var receivedPlayerDidFinishPlaying = false
    var receivedPlayerPlaying = false

    //the buffering status
    var bufferingCompleted = false
    
    //internal current playhead
    @objc dynamic var internalPlayHeadPosition: TimeInterval = 0
    
    var internalError: Error?
    var timeObserverToken: Any?
    
    /// Init
    override init() {
        super.init()
        startObserving()
    }
    
    override init(url URL: URL) {
        super.init(url: URL)
    }
    
    override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        startObserving()
    }
    
    override func replaceCurrentItem(with item: AVPlayerItem?) {
        super.replaceCurrentItem(with: item)
    }
    
    /// Deinit
    deinit {
        stopObserving()
    }
    
    /// Prepares the player with an AVPlayerItem
    func prepare(with url: URL) {
        newStatus(.initialized)
        let item = AVPlayerItem(url: url)
        replaceCurrentItem(with: item)
    }
    
    /// Plays
    override func play() {
        receivedPlayerDidFinishPlaying = false
        receivedPlayerPlaying = false
        super.play()
    }
    
    /// Finish play
    func stop() {
        guard let item = currentItem else {
            return
        }
        newStatus(.finished)
        
        // move to end and let the state update itself to terminate
        if item.duration != CMTime.indefinite {
            seek(to: item.duration)
        }
        
        //in case the player is playing a stream moving to the end won't stop
        //so pause the player. Since the state will already be set to finish it won't be affected
        pause()
    }
    
    /// Internal
    func startObserving() {
        if observingCurrentItem {
            return
        }
        addObserver(self, forKeyPath: "currentItem", options: [.initial, .new, .old], context: nil)
        observingCurrentItem = true
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { [weak self] time in
            self?.updatePlayhead(time)
        })
    }
    
    func stopObserving() {
        currentItem?.removeObserver(self, forKeyPath: "status")
        currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        currentItem?.removeObserver(self, forKeyPath: "timedMetadata")
        if observingCurrentItem {
            removeObserver(self, forKeyPath: "currentItem")
        }
        if let observer = timeObserverToken {
            removeTimeObserver(observer)
        }
        if currentItem != nil {
            removeObserver(self, forKeyPath: "timeControlStatus")
        }
    }

    func newStatus(_ newStatus: MediaPlayerStatus) {
        if newStatus != playerStatus {
            playerStatus = newStatus
            if newStatus != .failed {
                internalError = nil
            }
        }
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        //trigger currentPlayhead when internalPlayHeadPosition changes
        if key == "currentPlayhead" {
            return ["internalPlayHeadPosition"]
        } else {
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "currentItem":
            currentItemChanged(old: change?[.oldKey] as? AVPlayerItem, new: change?[.newKey] as? AVPlayerItem)
        case "status":
            currentItemStatusChanged()
        case "playbackBufferEmpty":
            playbackBufferEmptyChanged()
        case "playbackLikelyToKeepUp":
            playbackLikelyToKeepUpChanged()
        case "timedMetadata":
            timedMetadataChanged()
        case "timeControlStatus":
            timeControlStatusChanged()
        default:
            break
        }
    }

    
    func currentItemChanged(old oldItem: AVPlayerItem?, new newItem: AVPlayerItem?) {
        oldItem?.removeObserver(self, forKeyPath: "status")
        oldItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        oldItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        oldItem?.removeObserver(self, forKeyPath: "timedMetadata")
        if oldItem != nil {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: oldItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: oldItem)
            removeObserver(self, forKeyPath: "timeControlStatus")
        }
        
        newItem?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        newItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.initial, .new], context: nil)
        newItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.initial, .new], context: nil)
        newItem?.addObserver(self, forKeyPath: "timedMetadata", options: [.initial, .new], context: nil)
        
        if newItem != nil {
            NotificationCenter.default.addObserver(self,
                                                   selector:#selector(self.playerDidFinishPlaying(note:)),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: newItem)
            NotificationCenter.default.addObserver(self,
                                                   selector:#selector(self.playerFailedToPlay(note:)),
                                                   name: .AVPlayerItemFailedToPlayToEndTime,
                                                   object: newItem)
            addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: nil)
        } else {
            if oldItem?.status != .failed {
                newStatus(.initialized)
            }
        }
        internalPlayHeadPosition = 0
    }

    func currentItemStatusChanged() {
        guard let itemStatus = currentItem?.status else {
            return
        }
        
        switch itemStatus {
        case .unknown:
            newStatus(.unknown)
        case .failed:
            internalError = currentItem?.error
            replaceCurrentItem(with: nil)
            newStatus(.failed)
        case .readyToPlay:
            newStatus(.readyToPlay)
            //at this point the player might be set to play so update to playing
            if timeControlStatus == .playing {
                newStatus(.playing)
            }
        @unknown default:
            newStatus(.unknown)
        }
    }
    
    func playbackBufferEmptyChanged() {
        if currentItem?.isPlaybackBufferEmpty ?? false {
            newStatus(.buffering)
        }
    }
    
    func playbackLikelyToKeepUpChanged() {
        guard let currentItem = currentItem else {
            return
        }
        if currentItem.isPlaybackLikelyToKeepUp {
            if bufferingCompleted == true { //buffering was not called
                return
            }
            newStatus(.bufferingFinished)
            bufferingCompleted = true
        } else {
            bufferingCompleted = false
            newStatus(.buffering)
        }
    }

    func timedMetadataChanged() {
        guard let metadata = currentItem?.timedMetadata else {
            return
        }
        metadataItem = metadata
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        newStatus(.finished)
    }
    
    @objc func playerFailedToPlay(note: NSNotification) {
        if let error = note.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            internalError = error
        }
    }
    
    func timeControlStatusChanged() {
        switch timeControlStatus {
        case .paused:
            //it might arrive after the stop notification so ignore in that case
            if playerStatus != .initialized && receivedPlayerDidFinishPlaying == false {
                newStatus(.paused)
            }
        case .waitingToPlayAtSpecifiedRate:
            // ignore this state
            break
        case .playing:
            if playerStatus == .readyToPlay || playerStatus == .bufferingFinished || playerStatus == .paused {
                newStatus(.playing)
                receivedPlayerPlaying = true
            }
        @unknown default:
            newStatus(.unknown)
        }
    }
    
    func updatePlayhead(_ newTime: CMTime?) {
        guard
            let newTime = newTime,
            let currentItem = currentItem
        else {
            return
        }
        
        let itemDuration = CMTimeGetSeconds(currentItem.duration)
        internalPlayHeadPosition = min(CMTimeGetSeconds(newTime), itemDuration.isNaN ? Double.greatestFiniteMagnitude : itemDuration)
    }
    
    var internalCurrentPlayhead: TimeInterval {
        get {
            guard let currentItemTime = currentItem?.currentTime(), let duration = currentItem?.duration else {
                return 0
            }
            let currentTimeSeconds = max(0, CMTimeGetSeconds(currentItemTime))
            let durationSeconds = CMTimeGetSeconds(duration)
            return min(currentTimeSeconds.isNaN ? 0 : currentTimeSeconds, durationSeconds.isNaN ? Double.greatestFiniteMagnitude : durationSeconds)
        }
    }
    
    var internalCurrentDuration: TimeInterval {
        guard let duration = currentItem?.duration else {
            return 0
        }
        let seconds = CMTimeGetSeconds(duration)
        return seconds.isNaN ? Double.greatestFiniteMagnitude : seconds
    }

    /// MediaPlayerState protocol
    ///
    /// currentPlayhead is observable from AdswizzSDK, so any time you update it, the SDK will react to it's change
    /// Important notes:
    ///  1. The SDK might decide to query the value at random time, so your code must be prepared to reflect the exact time of the playhead . For example: AdswizzSDK recommands 'currentPlayhead' be updated every 1 sec but it might decide to query the value between updates. If the SDK queries this values while your player is 1.3 seconds into playing the value returned should be 1.3 seconds, not 1 second. To achieve this behaivour 'currentPlayhead' is not updated directly, but an intenal value called 'internalPlayHeadPosition' is used. Use the same approach in your code.
    ///  2. The SDK expects 'currentPlayhead' to be ascending order. Internally, the SDK will compute your reported playhead with the passed time since the last update it received from your player to decide if a continouos playing sequence is in progress. This means, that the SDK will detect if your player has done a seek or not. Continous playing will affect quartile reporting of the ad as per IAB documentation recommands.
    /// Expected values: any value in [0..duration] interval, values must be in ascending order
    /// Importance for the SDK: HIGH
    @objc dynamic var currentPlayhead: TimeInterval {
        get {
            return internalCurrentPlayhead
        }
    }
    
    /// playerStatus is very important. Your player should start with 'initialized' every time is begins playing. This is mandatory.
    /// Expected values: any MediaPlayerStatus value. Consult the Integration document for a complete state machine for your player.
    /// Importance for the SDK: HIGH
    @objc dynamic var playerStatus: MediaPlayerStatus = .initialized
    
    /// This value represents the duration in seconds of the media your player is currently playing. If you don't have it yet return 0.
    /// Expected values: [0..maxDurationOfTheMedia]
    /// Importance for the SDK: MEDIUM
    @objc dynamic var currentDuration: TimeInterval {
        return internalCurrentDuration
    }
    
    /// Whenever you have metadata, update this value. This is usefull when you use your player to play a stream. Failing to update the 'metadataItem' will result in AdswizzSDK not being able
    /// to use interactive ads while playing an Adswizz stream
    /// Expected values: any values of type [AVMetadataItem]
    /// Importance for the SDK: HIGH
    @objc dynamic var metadataItem: [AVMetadataItem]? = nil
    
    /// AVPlayer always buffers after paused
    /// Importance for the SDK: MEDIUM
    @objc dynamic var isBufferingWhilePaused: Bool { return true }
    
    /// Update volume if your player has the ability to change the volume of the content.
    /// Expected values: any values in interval [0..1] where 1 means 100% of the original value. If your player does not support volume changes return 1.
    /// Importance for the SDK: LOW
    //@objc dynamic override var volume: Float { 1.0 }
    
    /// Update this member with the last error that happend in your player. This will help the SDK to better report the erros back the AD servers.
    /// Expected values: any Error
    /// Importance for the SDK: LOW
    @objc dynamic var lastError: Error? {
        internalError
    }
    
    /// This should be a global setting for your player which informs the SDK what capabilities does your player support. This will be used by the SDK for better targeting.
    /// If you do not support any capability set this to nil
    /// Expected values: nil or a set of IAB capabilities
    /// Importance for the SDK: LOW
    @objc dynamic var capabilities: Set<MediaPlayerCapability>?
    
    /// Whenever your player is using a MediaPlayerCapability described above, update the state of your player. Each MediaPlayerCapability can return a state.
    /// Expected values: nil or a set of IAB state capabilities obtained from an MediaPlayerCapability object
    /// Importance for the SDK: LOW
    @objc dynamic var stateInfo: Set<MediaPlayerCapability.State>?
}
