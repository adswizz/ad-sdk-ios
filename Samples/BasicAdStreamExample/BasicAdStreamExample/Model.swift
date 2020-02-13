//
//  Model.swift
//  BasicAdStreamExample
//
//  Created by Teodor Cristea on 12/02/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzSDK

protocol ModelAdBreakDelegate: class {
    func modelDidStartAdBreak(_ model: Model)
    func modelDidEndAdBreak(_ model: Model)
}

protocol ModelStreamingDelegate: class {
    func modelDidStartStreaming(_ model: Model)
    func modelDidStopStreaming(_ model: Model)
    func modelDidPauseStreaming(_ model: Model)
    func modelDidResumeStreaming(_ model: Model)
}

enum Status {
    case playing
    case stopped
    case paused
}

class Model {
    let url = URL(string: "http://sdk.mobile.streaming.adswizz.com:8500/shakeDemo")
    let adServer = "demo.deliveryengine.adswizz.com"
    var adBreakManager: AdManager?
    var streamManager: AdswizzAdStreamManager?
    weak var streamDelegate: ModelStreamingDelegate?
    weak var adBreakDelegate: ModelAdBreakDelegate?
    private(set) var state: Status = .stopped
    var isReadyToPlay: Bool {
        return state != .stopped
    }
    
    func play() throws {
        guard let url = url else {
            throw ModelError.badStreamURL
        }
        
        try preparePlay()
        try streamManager?.play(with: url)
        state = .playing
        streamDelegate?.modelDidStartStreaming(self)
    }
    
    func stop(delegate: Bool = true) {
        streamManager?.stop()
        streamManager?.delegate = nil
        streamManager = nil
        state = .stopped
        if delegate {
            streamDelegate?.modelDidStopStreaming(self)
        }
    }

    func pause() {
        streamManager?.pause()
        state = .paused
        streamDelegate?.modelDidPauseStreaming(self)
    }
    
    func resume() {
        streamManager?.resume()
        state = .playing
        streamDelegate?.modelDidResumeStreaming(self)
    }
    
    func skipAd() {
        adBreakManager?.skipAd()
    }
}

private extension Model {
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
    }
}
