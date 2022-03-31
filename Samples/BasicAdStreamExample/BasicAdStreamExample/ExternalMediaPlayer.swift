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

class ExternalMediaPlayer: NSObject, MediaPlayerState {
    var receivedPlayerDidFinishPlaying = false
    var receivedPlayerPlaying = false
    var observingCurrentItem = false
    
    override init() {
        super.init()
    }
    
    var avPlayer = AVPlayer()
    func play(with url: URL) {
        receivedPlayerDidFinishPlaying = false
        let item = AVPlayerItem(url: url)
        avPlayer.replaceCurrentItem(with: item)
        startObserving()
        avPlayer.play()
        newStatus(.playing)
    }
    
    func stop() {
        receivedPlayerDidFinishPlaying = true
        newStatus(.finished)
        avPlayer.pause()
        stopObserving()
        avPlayer.replaceCurrentItem(with: nil)
    }
    
    func pause() {
        newStatus(.paused)
        avPlayer.pause()
    }
    
    func resume() {
        newStatus(.playing)
        avPlayer.play()
    }
    
    func startObserving() {
        if observingCurrentItem {
            return
        }
        avPlayer.addObserver(self, forKeyPath: "currentItem", options: [.initial, .new, .old], context: nil)
        observingCurrentItem = true
    }
    
    func stopObserving() {
        avPlayer.currentItem?.removeObserver(self, forKeyPath: "timedMetadata")
        if observingCurrentItem {
            avPlayer.removeObserver(self, forKeyPath: "currentItem")
        }
        observingCurrentItem = false
    }
    
    func currentItemChanged(old oldItem: AVPlayerItem?, new newItem: AVPlayerItem?) {
        oldItem?.removeObserver(self, forKeyPath: "timedMetadata")
 
        newItem?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        newItem?.addObserver(self, forKeyPath: "timedMetadata", options: [.initial, .new], context: nil)
        
        if newItem == nil {
            if oldItem?.status != .failed {
                newStatus(.initialized)
            }
        }
    }
    
    func newStatus(_ newStatus: MediaPlayerStatus) {
        if newStatus != playerStatus {
            playerStatus = newStatus
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "currentItem":
            currentItemChanged(old: change?[.oldKey] as? AVPlayerItem, new: change?[.newKey] as? AVPlayerItem)
        case "timedMetadata":
            timedMetadataChanged()
        default:
            break
        }
    }
    
    func timedMetadataChanged() {
        guard let metadata = avPlayer.currentItem?.timedMetadata else {
            return
        }
        
        metadataItem = metadata
    }
    
    /// MediaPlayerState protocol

    /// currentPlayhead is observable from AdswizzSDK, so any time you update it, the SDK will react to it's change
    /// Important notes:
    ///  1. The SDK might decide to query the value at random time, so your code must be prepared to reflect the exact time of the playhead . For example: AdswizzSDK recommands 'currentPlayhead' be updated every 1 sec but it might decide to query the value between updates. If the SDK queries this values while your player is 1.3 seconds into playing the value returned should be 1.3 seconds, not 1 second. To achieve this behaivour 'currentPlayhead' is not updated directly, but an intenal value called 'internalPlayHeadPosition' is used. Use the same approach in your code.
    ///  2. The SDK expects 'currentPlayhead' to be ascending order. Internally, the SDK will compute your reported playhead with the passed time since the last update it received from your player to decide if a continouos playing sequence is in progress. This means, that the SDK will detect if your player has done a seek or not. Continous playing will affect quartile reporting of the ad as per IAB documentation recommands.
    /// Expected values: any value in [0..duration] interval, values must be in ascending order
    /// Importance for the SDK: HIGH
    @objc dynamic var currentPlayhead: TimeInterval {
        guard let item = avPlayer.currentItem else { return 0.0 }
        return CMTimeGetSeconds(item.currentTime())
    }
    
    /// playerStatus is very important. Your player should start with 'initialized' every time is begins playing. This is mandatory.
    /// Expected values: any MediaPlayerStatus value. Consult the Integration document for a complete state machine for your player.
    /// Importance for the SDK: HIGH
    @objc dynamic var playerStatus: MediaPlayerStatus = .initialized
    
    /// This value represents the duration in seconds of the media your player is currently playing. If you don't have it yet return 0.
    /// Expected values: [0..maxDurationOfTheMedia]
    /// Importance for the SDK: MEDIUM
    @objc dynamic var currentDuration: TimeInterval {
        guard let item = avPlayer.currentItem else { return 0.0 }
        return CMTimeGetSeconds(item.duration)
    }
    
    /// Whenever you have metadata, update this value. This is usefull when you use your player to play a stream. Failing to update the 'metadataItem' will result in AdswizzSDK not being able
    /// to use interactive ads while playing an Adswizz stream
    /// Expected values: any values of type [AVMetadataItem]
    /// Importance for the SDK: HIGH
    @objc dynamic var metadataItem: [AVMetadataItem]? = nil
    
    @objc dynamic var isBufferingWhilePaused: Bool = false
    
    /// Update volume if your player has the ability to change the volume of the content.
    /// Expected values: any values in interval [0..1] where 1 means 100% of the original value. If your player does not support volume changes return 1.
    /// Importance for the SDK: LOW
    @objc dynamic var volume: Float = 1.0
    
    /// Update this member with the last error that happend in your player. This will help the SDK to better report the erros back the AD servers.
    /// Expected values: any Error
    /// Importance for the SDK: LOW
    @objc dynamic var lastError: Error? {
        avPlayer.error
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
