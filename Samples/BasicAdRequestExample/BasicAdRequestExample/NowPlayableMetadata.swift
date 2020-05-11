//
//  NowPlayableMetadata.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 16/09/2019.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import MediaPlayer

struct NowPlayableStaticMetadata {
    
    let assetURL: URL                   // MPNowPlayingInfoPropertyAssetURL
    let mediaType: MPNowPlayingInfoMediaType = .audio
                                        // MPNowPlayingInfoPropertyMediaType
    let isLiveStream: Bool              // MPNowPlayingInfoPropertyIsLiveStream
    
    let title: String                   // MPMediaItemPropertyTitle
    let artist: String?                 // MPMediaItemPropertyArtist
    let artwork: MPMediaItemArtwork?    // MPMediaItemPropertyArtwork
}

extension MPNowPlayingInfoCenter {
    func setNowPlayingMetadata(_ metadata: NowPlayableStaticMetadata) {
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
