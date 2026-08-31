//
//  NowPlayableStaticMetadata.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import Foundation
import MediaPlayer

public struct NowPlayableStaticMetadata: Sendable {
    public let assetURL: URL                                     // MPNowPlayingInfoPropertyAssetURL
    public let mediaType: MPNowPlayingInfoMediaType              // MPNowPlayingInfoPropertyMediaType
    public let isLiveStream: Bool                                // MPNowPlayingInfoPropertyIsLiveStream
    public let title: String                                     // MPMediaItemPropertyTitle
    public let artist: String?                                   // MPMediaItemPropertyArtist
    public nonisolated(unsafe) let artwork: MPMediaItemArtwork?  // MPMediaItemPropertyArtwork

    public init(
        assetURL: URL,
        mediaType: MPNowPlayingInfoMediaType = .audio,
        isLiveStream: Bool,
        title: String,
        artist: String?,
        artwork: MPMediaItemArtwork?
    ) {
        self.assetURL = assetURL
        self.mediaType = mediaType
        self.isLiveStream = isLiveStream
        self.title = title
        self.artist = artist
        self.artwork = artwork
    }
}

extension MPNowPlayingInfoCenter {
    public func setNowPlayingMetadata(_ metadata: NowPlayableStaticMetadata) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPNowPlayingInfoPropertyAssetURL] = metadata.assetURL
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = metadata.mediaType.rawValue
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = metadata.isLiveStream
        nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.artist
        nowPlayingInfo[MPMediaItemPropertyArtwork] = metadata.artwork
        self.nowPlayingInfo = nowPlayingInfo
    }
}
