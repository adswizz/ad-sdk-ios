//
//  ExternalMediaPlayer.swift
//  AudioAdCoreTests
//
//  Created by Bogdan Cosescu on 08/04/2019.
//  Copyright © 2019 AdsWizz, inc. All rights reserved.
//

import AVFoundation
import AdswizzSDK


/// ExternalMediaPlayer is a fake player that implementes AdswizzSDK's MediaPlayerState protocol to highlight how your player should behave
class ExternalMediaPlayer: NSObject, MediaPlayerState {

    /// MediaPlayerState protocol

    /// currentPlayhead is observable from AdswizzSDK, so any time you update it, the SDK will react to it's change
    /// Important notes:
    ///  1. The SDK might decide to query the value at random time, so your code must be prepared to reflect the exact time of the playhead . For example: AdswizzSDK recommands 'currentPlayhead' be updated every 1 sec but it might decide to query the value between updates. If the SDK queries this values while your player is 1.3 seconds into playing the value returned should be 1.3 seconds, not 1 second. To achieve this behaivour 'currentPlayhead' is not updated directly, but an intenal value called 'internalPlayHeadPosition' is used. Use the same approach in your code.
    ///  2. The SDK expects 'currentPlayhead' to be ascending order. Internally, the SDK will compute your reported playhead with the passed time since the last update it received from your player to decide if a continouos playing sequence is in progress. This means, that the SDK will detect if your player has done a seek or not. Continous playing will affect quartile reporting of the ad as per IAB documentation recommands.
    /// Expected values: any value in [0..duration] interval, values must be in ascending order
    /// Importance for the SDK: HIGH
    @objc dynamic public var currentPlayhead: TimeInterval {
        get {
            //if the player is not playing return last stored position
            guard let lastTimeEvent = lastTimeEvent, playerStatus == .playing else {
                return internalPlayHeadPosition
            }
            
            //compute how much time has passed since the last time we acctualy updated 'internalPlayHeadPosition' and now
            let now = Date().timeIntervalSince1970
            return min(internalPlayHeadPosition + now - lastTimeEvent, currentDuration)
        }
    }
    
    /// playerStatus is very important. Your player should start with 'initialized' every time is begins playing. This is mandatory.
    /// Expected values: any MediaPlayerStatus value. Consult the Integration document for a complete state machine for your player.
    /// Importance for the SDK: HIGH
    @objc dynamic public var playerStatus: MediaPlayerStatus = .initialized {
        willSet {
            kLog.log("ExternalMediaPlayer: setting status to \(newValue.stringValue)")
        }
    }
    
    /// Whenever you have metadata, update this value. This is usefull when you use your player to play a stream. Failing to update the 'metadataItem' will result in AdswizzSDK not being able
    /// to use interactive ads while playing an Adswizz stream
    /// Expected values: any values of type [AVMetadataItem]
    /// Importance for the SDK: HIGH
    @objc dynamic public var metadataItem: [AVMetadataItem]?
        
    /// This value represents the duration in seconds of the media your player is currently playing. If you don't have it yet return 0.
    /// Expected values: [0..maxDurationOfTheMedia]
    /// Importance for the SDK: MEDIUM
    @objc public var currentDuration: TimeInterval {
        get {
            return duration ?? 0
        }
    }
    
    /// Update volume if your player has the ability to change the volume of the content.
    /// Expected values: any values in interval [0..1] where 1 means 100% of the original value. If your player does not support volume changes return 1.
    /// Importance for the SDK: LOW
    @objc dynamic public var volume: Float = 1
    
    /// This is optional. This should be a global setting for your player which informs the SDK that it will continue to buffer data for some time after it was paused. This is usefull for the SDK while playing  a stream.
    /// Expected values: true if the player will continue buffering data after pausing, or false if the player suspends buffering while pausing.
    /// Importance for the SDK: LOW
    @objc public var isBufferingWhilePaused: Bool = false
    
    /// Update this member with the last error that happend in your player. This will help the SDK to better report the erros back the AD servers.
    /// Expected values: any Error
    /// Importance for the SDK: LOW
    @objc public var lastError: Error?
    
    /// This should be a global setting for your player which informs the SDK what capabilities does your player support. This will be used by the SDK for better targeting.
    /// If you do not support any capability set this to nil
    /// Expected values: nil or a set of IAB capabilities
    /// Importance for the SDK: LOW
    @objc public var capabilities: Set<MediaPlayerCapability>?
    
    /// Whenever your player is using a MediaPlayerCapability described above, update the state of your player. Each MediaPlayerCapability can return a state.
    /// Expected values: nil or a set of IAB state capabilities obtained from an MediaPlayerCapability object
    /// Importance for the SDK: LOW
    @objc public var stateInfo: Set<MediaPlayerCapability.State>?
    
    
    /// ExternalMediaPlayer internals
    private var url: String?                    // mocked url for the media
    private var duration: TimeInterval?         // duration of the media currently played by the player
    private var timer: Timer?                   // internal timer to simultate playing
    private var lastTimeEvent: TimeInterval?    // internal bookeeping for the last time a currentDuration event was triggered
    private static let playheadPeriod = 1.0     // interval at which to update the playhead. Using 1 sec as recommend by the SDK but could be higher. Don't go bellow 1 sec as it will create unnecessary calls to the SDK.
    private static let bufferingPeriod = 0.2    // a buffering period of 200ms to express stages of buffering in your player.
    private var bufferingTimer: Timer?          // internal buffering timer
    @objc private dynamic var internalPlayHeadPosition: TimeInterval = 0 /*using this 'internalPlayHeadPosition' variable to simulate updates to 'currentPlayhead' for AdswizzSDK. Use the same approach in your code*/ {
        willSet {
            kLog.log("ExternalMediaPlayer: setting playHead to \(newValue)")
        }
    }

    // override keyPathsForValuesAffectingValue and return 'internalPlayHeadPosition' as the affected keyPath for 'currentPlayhead'
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        //trigged currentPlayhead when internalPlayHeadPosition changes
        if key == "currentPlayhead" {
            return ["internalPlayHeadPosition"]
        }
        else {
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
}

//player operations. These are basic operation your player might implement, so not all code applies to your situation.
extension ExternalMediaPlayer {
    
    func play(_ url: String, duration: TimeInterval) {
        //just checking
        if self.timer != nil && self.url != nil {
            stop()
        }
        
        kLog.log("ExternalMediaPlayer: playing \(url) with duration \(duration)")
        self.url = url
        self.duration = duration
        
        //IMPORTANT: set the state to 'initialized' to signal the SDK you are about to begin playing.
        playerStatus = .initialized
        
        //MOCKING: add a buffering stage to simultate loading of the url
        playerStatus = .buffering
        
        //IMPORTANT: update 'internalPlayHeadPosition' as you are about to begin playing
        internalPlayHeadPosition = 0
        
        //MOCKING: begin buffering
        bufferingTimer?.invalidate()
        bufferingTimer = Timer.scheduledTimer(withTimeInterval: ExternalMediaPlayer.bufferingPeriod, repeats: false, block: { [weak self] _ in
            //IMPORTANT: your player has finished buffering so update the state accordingly
            self?.playerStatus = .bufferingFinished
            self?.createTimer()
            //IMPORTANT: your player is playing now, so update the state to playing
            self?.playerStatus = .playing
        })
    }

    func pause() {
        bufferingTimer?.invalidate()
        bufferingTimer = nil
        guard let timer = timer, timer.isValid == true else {
            return
        }
        kLog.log("ExternalMediaPlayer: pausing")
        timer.invalidate()
        
        //IMPORTANT: if your player is paused set the state to paused
        playerStatus = .paused
    }
    
    func resume() {
        guard let timer = timer, timer.isValid == false else {
            return
        }
        kLog.log("ExternalMediaPlayer: resuming")
        createTimer()
        
        //IMPORTANT: if your player has resumed from paused set the state to playing
        playerStatus = .playing
    }
        
    func stop() {
        bufferingTimer?.invalidate()
        bufferingTimer = nil
        if timer == nil {
            return
        }
        
        kLog.log("ExternalMediaPlayer: stopping")
        timer?.invalidate()
        timer = nil
        
        //IMPORTANT: if your player has finished playing set the state to 'finished'. Whenever you are done with media provided by AdswizzSDK set the state to 'finished'
        playerStatus = .finished
    }
    
    //this operation is just to demonstrate what the impact of a seek function will have on AdswizzSDK.
    //'internalPlayHeadPosition' gets updated with the offeset
    func seek(_ offset: TimeInterval) {
        guard let duration = duration else {
            return
        }
        kLog.log("ExternalMediaPlayer: seeking")
        let newPosition = internalPlayHeadPosition + offset
        internalPlayHeadPosition = min(max(0, newPosition), duration)
        if playerStatus == .playing {
            lastTimeEvent = Date().timeIntervalSince1970
        }
    }

}

//buffering helpers
extension ExternalMediaPlayer {
    func induceBuffering(for seconds: TimeInterval) {
        if playerStatus == .buffering {
            return
        }
        
        let shouldRestart = (playerStatus == .playing)
        if timer != nil {
            timerAction()
            timer?.invalidate()
        }
        
        playerStatus = .buffering
        
        bufferingTimer?.invalidate()
        bufferingTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [weak self] _ in
            self?.playerStatus = .bufferingFinished
            if shouldRestart {
                self?.resume()
            }
        })
    }
}

private extension ExternalMediaPlayer {
    func createTimer() {
        timer?.invalidate()
        lastTimeEvent = Date().timeIntervalSince1970
        timer = Timer.scheduledTimer(withTimeInterval: ExternalMediaPlayer.playheadPeriod, repeats: true, block: { [weak self] _ in
            self?.timerAction()
        })
    }

    func timerAction() {
        guard let lastTimeEvent = lastTimeEvent, let duration = duration else {
            timer?.invalidate()
            return
        }
        
        if playerStatus == .finished {
            return
        }
        
        let now = Date().timeIntervalSince1970
        let passedTime = internalPlayHeadPosition + now - lastTimeEvent
        if passedTime >= duration {
            //IMPORTANT: the player is at the end of the media so update 'internalPlayHeadPosition' with the duration of media as way to conclude the playing cycle.
            internalPlayHeadPosition = duration
            stop()
            return
        } else {
            if duration - passedTime < ExternalMediaPlayer.playheadPeriod {
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: duration - passedTime, repeats: true, block: { [weak self] _ in
                    self?.timerAction()
                })
            }
        }
        self.lastTimeEvent = now
        //IMPORTANT: the player has played 1 sec of media content so update the playhead position
        internalPlayHeadPosition = passedTime
    }
}

extension MediaPlayerStatus {
    var stringValue: String {
        switch self {
        case .unknown: return "unknown"
        case .initialized: return "initialized"
        case .buffering: return "buffering"
        case .bufferingFinished: return "bufferingFinished"
        case .readyToPlay: return "readyToPlay"
        case .playing: return "playing"
        case .paused: return "paused"
        case .finished: return "finished"
        case .failed: return "failed"
        @unknown default:
            return ""
        }
    }
}
