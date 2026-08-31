//
//  PodcastAdViewModel+AdPodcastManagerDelegate.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK

extension PodcastAdViewModel: AdPodcastManagerDelegate {
    public func adPodcastManager(_ adPodcastManager: AdPodcastManager, didFailPlaying url: URL, error: any Error) {
        print("Failed to play podcast at \(url) with error \(error.localizedDescription)")
    }

    public func adPodcastManagerPlayerShouldPause(_ adPodcastManager: AdPodcastManager) {
        onPodcastPlayerShouldPause()
    }

    public func adPodcastManagerPlayerShouldResume(_ adPodcastManager: AdPodcastManager) {
        onPodcastPlayerShouldResume()
    }

    public func adPodcastManagerPlayer(_ adPodcastManager: AdPodcastManager, shouldSeekTo time: TimeInterval, completion: @escaping @Sendable () -> Void) {
        onPodcastPlayerShouldSeek(to: time, completion: completion)
    }

    public func adPodcastManager(_ adPodcastManager: AdPodcastManager, willStartPlaying url: URL) {
        print("Will play podcast at \(url)")
        isPlaying = true
        onWillStartPlaying(url: url)
    }

    public func adPodcastManager(_ adPodcastManager: AdPodcastManager, stateChanged state: MediaPlayerStatus) {
        print("Podcast manager state changed: \(state.stringValue)")
    }

    public func adPodcastManager(_ adPodcastManager: AdPodcastManager, didReceive manager: AdManager) {
        print("AdBreaks loaded - adCount=\(manager.adCount) totalDuration=\(manager.totalAdsDuration)")
        onAdBreakReceived(manager: manager)
    }

    public func adPodcastManager(_ adPodcastManager: AdPodcastManager, playheadChanged playhead: TimeInterval, duration: TimeInterval) {
        onPlayheadChanged(playhead: playhead, duration: duration)
    }
}
