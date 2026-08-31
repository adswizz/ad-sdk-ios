//
//  WatchSupport.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 16.06.2026.
//

import Foundation

public enum WatchPlaybackState: String, Codable, Sendable {
    case playingAds
    case playingContent
}

@MainActor public protocol WatchSupport {
    var hasSupport: Bool { get }
    func sendMessage(_ state: WatchPlaybackState)
}
