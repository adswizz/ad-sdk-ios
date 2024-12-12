//
//  ServerSideModelView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 04.12.2024.
//

import AVFoundation
import AdswizzSDK

class ServerSideModelView: ObservableObject {
    private var adManager: AdManager?
    private var streamManager: AdswizzAdStreamManager?
    private let streamURL = "http://sdk.mobile.streaming.adswizz.com:8500/shakeDemo"
    private let adServer = "demo.deliveryengine.adswizz.com"
    @Published var isPlaying: Bool = false
    
    init() {
        configureStreamManager()
    }
    
    private func configureStreamManager() {
        guard let url = URL(string: streamURL) else { return }
        do {
            streamManager = try AdswizzAdStreamManager.Builder()
                .with(adServer: adServer)
                .build()
            streamManager?.delegate = self
            try streamManager?.prepare(with: url)
        } catch {
            print(error)
        }
    }
    
    func start() {
        guard let url = URL(string: streamURL) else { return }
        do {
            try streamManager?.play(with: url)
            isPlaying = true
        } catch {
            print("Oops, the request is not valid")
        }
    }
    
    func stop() {
        streamManager?.stop()
        isPlaying = false
    }
    
    func skip() {
        adManager?.skipAd()
    }
}

extension ServerSideModelView: AdStreamManagerDelegate {
    func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL) {
        print("Received ad stream manager event: willStartPlaying -> \(url)")
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakStarted manager: AdManager) {
        print("Received ad stream manager event: adBreakStarted")
        adManager = manager
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, stateChanged state: MediaPlayerStatus) {
        print("Received ad stream manager event: stateChanged -> \(state.rawValue)")
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakEnded manager: AdManager) {
        print("Received ad stream manager event: adBreakEnded")
        adManager?.reset()
        adManager = nil
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, metadataChanged metadata: [AVMetadataItem]) {
        print("Received ad stream manager event: metadataChanged")
    }
    
    func adStreamManagerWillReconnect(_ adstreamManager: AdStreamManager) {
        print("Received ad stream manager event: willReconnect")
    }
    
    func adStreamManagerPlayerShouldPause(_ adstreamManager: AdStreamManager) {
        print("Received ad stream manager event: playerShouldPause")
    }
    
    func adStreamManagerPlayerShouldResume(_ adstreamManager: AdStreamManager) {
        print("Received ad stream manager event: playerShouldResume")
    }
}
