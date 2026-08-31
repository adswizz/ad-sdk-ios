//
//  MediaPlayerStatus+StringValue.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK

extension MediaPlayerStatus {
    public var stringValue: String {
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
            return "unknown"
        }
    }

    public var toString: String { stringValue }
}
