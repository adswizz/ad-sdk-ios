//
//  PodcastModelView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 02.12.2024.
//

import Foundation
import AdswizzSDK

class PodcastModelView: ObservableObject {
    private var adManager: AdManager?
    private var podcastManager: AdswizzAdPodcastManager?
    private let adServer = "demo.deliveryengine.adswizz.com"
    private let podcastURL: String
    @Published var isPlaying: Bool = false
    
    init(podcastURL: String) {
        self.podcastURL = podcastURL
        configurePodcastManager()
    }
    
    private func configurePodcastManager() {
        do {
            podcastManager = try AdswizzAdPodcastManager.Builder()
                .with(adServer: adServer)
                .with(httpProtocol: .http)
                .build()
            podcastManager?.delegate = self
        } catch {
            print("Oops, the request is not valid")
        }
    }
    
    func start() {
        guard let url = URL(string: podcastURL) else { return }
        do {
            try podcastManager?.play(with: url)
            isPlaying = true
        } catch {
            print("Oops, the request is not valid")
        }
    }
    
    func stop() {
        podcastManager?.stop()
        isPlaying = false
    }
    
    func skip() {
        adManager?.skipAd()
    }
}

extension PodcastModelView: AdPodcastManagerDelegate {
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, willStartPlaying url: URL) {
        print("Will play podcast at \(url)")
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didFailPlaying url: URL, error: Error) {
        print("Failed to play podcast at \(url) with error \(error.localizedDescription)")
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didReceive manager: AdManager) {
        print("AdBreaks loaded")
        print("Received AdManager adCount=\(manager.ads.count) \(manager.ads.compactMap { $0.duration }.reduce(0, +))")
        
        adManager = manager
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, stateChanged state: MediaPlayerStatus) {}
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, playheadChanged playhead: TimeInterval, duration: TimeInterval) {
        print("Playhead changed \(playhead) out of total duration \(duration)")
    }
    
    func adPodcastManagerPlayerShouldPause(_ adPodcastManager: AdPodcastManager) {}
    
    func adPodcastManagerPlayerShouldResume(_ adPodcastManager: AdPodcastManager) {}
    
    func adPodcastManagerPlayer(_ adPodcastManager: AdPodcastManager, shouldSeekTo time: TimeInterval, completion: @escaping () -> Void) {}
}
