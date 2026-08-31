//
//  ExternalMediaPlayer.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//  Copyright © 2026 Adswizz. All rights reserved.
//

import Foundation
import AdswizzSDK
import AVKit
import UIKit

@MainActor public final class ExternalMediaPlayer: NSObject, MediaPlayerState, Isolatable {
    
    public let avPlayer: AVPlayer
    
    /// A view that renders this player's video frames (backed by `AVPlayerLayer`).
    ///
    /// When this player is used as an external player (`AdManagerSettings.player`), the SDK does not render the video itself — the app owns playback and must display it.
    public lazy var playerView: ExternalPlayerVideoView = {
        let view = ExternalPlayerVideoView()
        view.player = avPlayer
        return view
    }()
    
    private var receivedPlayerDidFinishPlaying = false
    private var receivedPlayerPlaying = false

    //the buffering status
    public var bufferingCompleted = false
    //internal current playhead
    @objc dynamic private var internalPlayHeadPosition: TimeInterval = 0
    //internal mirror of avPlayer.volume, kept in sync via KVO so `volume` stays observable
    @objc dynamic private var internalVolume: Float = 1.0

    var internalError: Error?
    
    private var timeObserverToken: Any?
    private var playerObservations: [NSKeyValueObservation] = []
    private var itemObservations: [NSKeyValueObservation] = []
    private var notificationObservers: [Any] = []
    
    private var metadataOutput: AVPlayerItemMetadataOutput?

    public override init() {
        avPlayer = AVPlayer()
        super.init()
        startObserving()
    }
    
    public init(url: URL) {
        avPlayer = AVPlayer(url: url)
        super.init()
        startObserving()
    }
    
    public init(playerItem item: AVPlayerItem?) {
        avPlayer = AVPlayer(playerItem: item)
        super.init()
        startObserving()
    }
    
    public func replaceCurrentItem(with item: AVPlayerItem?) {
        avPlayer.replaceCurrentItem(with: item)
    }
    
    public var currentItem: AVPlayerItem? {
        avPlayer.currentItem
    }
    
    public func pause() {
        avPlayer.pause()
    }
    
    public func seek(to time: CMTime) {
        avPlayer.seek(to: time)
    }
    
    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping @Sendable (Bool) -> Void) {
        avPlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }
    
    isolated deinit {
        if let token = timeObserverToken {
            avPlayer.removeTimeObserver(token)
        }
    }
    
    /// Prepares the player with an AVPlayerItem
    public func prepare(with url: URL) {
        newStatus(.initialized)
        let item = AVPlayerItem(url: url)
        replaceCurrentItem(with: item)
    }
    
    /// Plays
    public func play() {
        receivedPlayerDidFinishPlaying = false
        receivedPlayerPlaying = false
        avPlayer.play()
    }
    
    /// Finish play
    public func stop() {
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
    
    private func startObserving() {
        // Observe currentItem changes on the wrapped player
        playerObservations.append(
            avPlayer.observe(\.currentItem, options: [.initial, .new, .old]) { [weak self] _, change in
                self?.onMainActor {
                    self?.currentItemChanged(old: change.oldValue ?? nil, new: change.newValue ?? nil)
                }
            }
        )
        
        playerObservations.append(
            avPlayer.observe(\.volume, options: [.initial, .new]) { [weak self] _, change in
                guard let newValue = change.newValue else { return }
                self?.onMainActor { self?.internalVolume = newValue }
            }
        )

        // Periodic time observer
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] time in
            self?.onMainActor { self?.updatePlayhead(time) }
        })
    }
    
    private func observeItem(_ item: AVPlayerItem) {
        // Status
        itemObservations.append(
            item.observe(\.status, options: [.new]) { [weak self] _, _ in
                self?.onMainActor { self?.currentItemStatusChanged() }
            }
        )

        // Buffering
        itemObservations.append(
            item.observe(\.isPlaybackBufferEmpty, options: [.initial, .new]) { [weak self] _, _ in
                self?.onMainActor { self?.playbackBufferEmptyChanged() }
            }
        )
        itemObservations.append(
            item.observe(\.isPlaybackLikelyToKeepUp, options: [.initial, .new]) { [weak self] _, _ in
                self?.onMainActor { self?.playbackLikelyToKeepUpChanged() }
            }
        )

        // Timed metadata (using AVPlayerItemMetadataOutput instead of deprecated timedMetadata KVO)
        let output = AVPlayerItemMetadataOutput()
        output.setDelegate(self, queue: .main)
        item.add(output)
        metadataOutput = output

        // TimeControlStatus on the wrapped player (observed per-item lifecycle)
        itemObservations.append(
            avPlayer.observe(\.timeControlStatus, options: [.new]) { [weak self] _, _ in
                self?.onMainActor { self?.timeControlStatusChanged() }
            }
        )

        // Notifications
        notificationObservers.append(
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak self] _ in
                self?.onMainActor { self?.newStatus(.finished) }
            }
        )
        notificationObservers.append(
            NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: item, queue: .main) { [weak self] notification in
                let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
                self?.onMainActor {
                    if let error {
                        self?.internalError = error
                    }
                }
            }
        )
    }
    
    private func unobserveItem() {
        itemObservations.removeAll()
        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
        notificationObservers.removeAll()
        if let output = metadataOutput {
            currentItem?.remove(output)
            metadataOutput = nil
        }
    }
    
    func currentItemChanged(old oldItem: AVPlayerItem?, new newItem: AVPlayerItem?) {
        unobserveItem()

        if let newItem {
            observeItem(newItem)
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
            if avPlayer.timeControlStatus == .playing {
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

    func timeControlStatusChanged() {
        switch avPlayer.timeControlStatus {
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
    
    func newStatus(_ newStatus: MediaPlayerStatus) {
        if newStatus != playerStatus {
            playerStatus = newStatus
            if newStatus != .failed {
                internalError = nil
            }
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
    
    public override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        //trigger currentPlayhead when internalPlayHeadPosition changes, and volume when internalVolume changes
        switch key {
        case "currentPlayhead":
            return ["internalPlayHeadPosition"]
        case "volume":
            return ["internalVolume"]
        default:
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
    
    var internalCurrentPlayhead: TimeInterval {
        guard let currentItemTime = currentItem?.currentTime(), let duration = currentItem?.duration else {
            return 0
        }
        let currentTimeSeconds = max(0, CMTimeGetSeconds(currentItemTime))
        let durationSeconds = CMTimeGetSeconds(duration)
        return min(currentTimeSeconds.isNaN ? 0 : currentTimeSeconds, durationSeconds.isNaN ? Double.greatestFiniteMagnitude : durationSeconds)
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
    @objc dynamic public var currentPlayhead: TimeInterval {
        internalCurrentPlayhead
    }
    
    /// playerStatus is very important. Your player should start with 'initialized' every time is begins playing. This is mandatory.
    /// Expected values: any MediaPlayerStatus value. Consult the Integration document for a complete state machine for your player.
    /// Importance for the SDK: HIGH
    @objc dynamic public var playerStatus: MediaPlayerStatus = .initialized
    
    /// This value represents the duration in seconds of the media your player is currently playing. If you don't have it yet return 0.
    /// Expected values: [0..maxDurationOfTheMedia]
    /// Importance for the SDK: MEDIUM
    @objc dynamic public var currentDuration: TimeInterval {
        internalCurrentDuration
    }
    
    /// Whenever you have metadata, update this value. This is usefull when you use your player to play a stream. Failing to update the 'metadataItem' will result in AdswizzSDK not being able
    /// to use interactive ads while playing an Adswizz stream
    /// Expected values: any values of type [AVMetadataItem]
    /// Importance for the SDK: HIGH
    @objc dynamic public var metadataItem: [AVMetadataItem]? = nil
    
    /// AVPlayer always buffers after paused
    /// Importance for the SDK: MEDIUM
    @objc dynamic public var isBufferingWhilePaused: Bool { true }

    /// Update volume if your player has the ability to change the volume of the content.
    /// Expected values: any values in interval [0..1] where 1 means 100% of the original value. If your player does not support volume changes return 1.
    /// Importance for the SDK: LOW
    @objc dynamic public var volume: Float {
        get { internalVolume }
        set { avPlayer.volume = newValue }
    }

    /// Update this member with the last error that happend in your player. This will help the SDK to better report the erros back the AD servers.
    /// Expected values: any Error
    /// Importance for the SDK: LOW
    @objc dynamic public var lastError: Error? {
        internalError
    }
    
    /// This should be a global setting for your player which informs the SDK what capabilities does your player support. This will be used by the SDK for better targeting.
    /// If you do not support any capability set this to nil
    /// Expected values: nil or a set of IAB capabilities
    /// Importance for the SDK: LOW
    @objc dynamic public var capabilities: Set<MediaPlayerCapability>?
    
    /// Whenever your player is using a MediaPlayerCapability described above, update the state of your player. Each MediaPlayerCapability can return a state.
    /// Expected values: nil or a set of IAB state capabilities obtained from an MediaPlayerCapability object
    /// Importance for the SDK: LOW
    @objc dynamic public var stateInfo: Set<MediaPlayerCapability.State>?
}

extension ExternalMediaPlayer: @preconcurrency AVPlayerItemMetadataOutputPushDelegate {
    public func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        let items = groups.flatMap { $0.items }
        guard !items.isEmpty else { return }
        metadataItem = items
    }
}

/// A `UIView` whose backing layer is an `AVPlayerLayer`, used to render an external player's video.
@MainActor public final class ExternalPlayerVideoView: UIView {
    public override class var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    /// The player whose frames are displayed.
    public var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
}
