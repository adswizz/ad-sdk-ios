//
//  MediaPlayer.swift
//  AdvancedHLSInterstitialExample
//
//  Created by George Mihoc on 18.12.2024.
//

import AdswizzSDK

class MediaPlayer: ExternalMediaPlayer {}

extension MediaPlayerStatus {
    var stringValue: String {
        switch self {
        case .initialized: return "initialized"
        case .buffering: return "buffering"
        case .bufferingFinished: return "bufferingFinished"
        case .readyToPlay: return "readyToPlay"
        case .playing: return "playing"
        case .paused: return "paused"
        case .finished: return "finished"
        case .failed: return "failed"
        case .unknown: return "unknown"
        @unknown default:
            return "unknown"
        }
    }
}

extension AdEventType {
    func toString() -> String {
        switch self {
        case .adCompleted: return "adCompleted"
        case .allAdsCompleted: return "allAdsCompleted"
        case .didFinishPlaying: return "didFinishPlaying"
        case .preparingForPlay: return "preparingForPlay"
        case .readyForPlay: return "readyForPlay"
        case .didPausePlaying: return "didPausePlaying"
        case .didStartPlaying: return "didStartPlaying"
        case .firstQuartile: return "firstQuartile"
        case .midpoint: return "midpoint"
        case .thirdQuartile: return "thirdQuartile"
        case .complete: return "complete"
        case .unknown:
            fallthrough
        @unknown default:
            return "unknown"
        }
    }
}
