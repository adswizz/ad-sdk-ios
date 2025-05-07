//
//  Model.swift
//  BasicAdStreamExample
//
//  Created by Teodor Cristea on 12/02/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzSDK

protocol ModelAdBreakDelegate: AnyObject {
    func modelDidStartAdBreak(_ model: Model)
    func modelDidEndAdBreak(_ model: Model)
}

protocol ModelStreamingDelegate: AnyObject {
    func modelDidStartStreaming(_ model: Model)
    func modelDidStopStreaming(_ model: Model)
    func modelDidPauseStreaming(_ model: Model)
    func modelDidResumeStreaming(_ model: Model)
    func model(_ model: Model, didReceive dvrMetadata: AdStreamDVRMetadata?)
}

enum Status {
    case playing
    case stopped
    case paused
}

class Model {
    //default stream URL when a custom URL is not provided
    let defaultStreamUrl = URL(string: "https://streaming.sdk.eks.devel.adswizz.com/shakeDemo")
    
    // constants
    let url: URL?
    let adServer = "demo.deliveryengine.adswizz.com" //replace the adserver with the one received from Adswizz
    let capabilities: [AdStreamCapability]
    
    //ad breaks related
    var adBreakManager: AdManager?
    var streamManager: AdswizzAdStreamManager?
    weak var streamDelegate: ModelStreamingDelegate?
    weak var adBreakDelegate: ModelAdBreakDelegate?
    
    //DVR related
    var dvrMetadata: AdStreamDVRMetadata?
    
    //states
    private(set) var state: Status = .stopped
    var isReadyToPlay: Bool {
        return state != .stopped
    }
    
    //External player related
    var player = ExternalMediaPlayer()
    var isUsingExternalPlayer = false
    
    //Initializer
    init(streamUrl: URL? = nil, capabilities: [AdStreamCapability]) {
        self.url = streamUrl ?? defaultStreamUrl
        self.capabilities = capabilities
    }
    
    func preparePlay() throws {
        // Stop current streaming if running
        stop(delegate: false)
        
        // Create a new stream manager
        if streamManager == nil {
            streamManager = try AdswizzAdStreamManager.Builder()
                .with(adServer: adServer)               //Mandatory
                .with(httpProtocol: .https)             //Optional: defaults to https protocol for the ad server
                .with(companionZones: "")               //Optional: companion zone provided by a PIM
                .build()
            streamManager?.delegate = self
        }
        
        let settings = AdStreamManagerSettings()
        if isUsingExternalPlayer {
            settings.player = player
            print("Playing with external player")
        }
        capabilities.forEach {
            settings.addCapability($0)
        }
        streamManager?.adStreamManagerSettings = settings
    }
    
    func play() throws {
        guard let url = url else {
            throw ModelError.badStreamURL
        }
        
        if streamManager == nil {
            try preparePlay()
        }
                
        try streamManager?.play(with: url)
        state = .playing
        streamDelegate?.modelDidStartStreaming(self)
    }
    
    func play(with timestamp: NSNumber) throws {
        guard let url = url else {
            throw ModelError.badStreamURL
        }
        stop(delegate: false, removeStreamManager: false)
        state = .playing
        try streamManager?.play(with: url, timestamp: timestamp)
    }
    
    func stop(delegate: Bool = true, removeStreamManager: Bool = true) {
        if isUsingExternalPlayer {
            player.stop()
        } else { // Calling stop for isUsingExternalPlayer doesn't have any effect, only needed for internal player
            streamManager?.stop()
        }
        if removeStreamManager {
            streamManager?.delegate = nil
            streamManager = nil
        }
        state = .stopped
        if delegate {
            streamDelegate?.modelDidStopStreaming(self)
        }
    }

    func pause() {
        if isUsingExternalPlayer {
            player.pause()
        } else {
            streamManager?.pause()
        }
        state = .paused
        streamDelegate?.modelDidPauseStreaming(self)
    }
    
    func resume() {
        if isUsingExternalPlayer {
            player.play()
        } else {
            streamManager?.resume()
        }
        state = .playing
        streamDelegate?.modelDidResumeStreaming(self)
    }
    
    func skipAd() {
        adBreakManager?.skipAd()
    }
}
