//
//  ViewController+NowPlaying.swift
//  BasicAdRequestWatchExample
//
//  Created by Teodor Cristea on 05/03/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import MediaPlayer

extension ViewController {
    func updateNowPlaying(with data: NowPlayableStaticMetadata) {
        MPNowPlayingInfoCenter.default().setNowPlayingMetadata(data)
        // Configure interface objects here.
        let remoteCenter = MPRemoteCommandCenter.shared()
        remoteCenter.playCommand.isEnabled = true
        remoteCenter.pauseCommand.isEnabled = true
        remoteCenter.playCommand.removeTarget(nil)
        remoteCenter.pauseCommand.removeTarget(nil)
        remoteCenter.playCommand.addTarget { [weak self] _ in
            self?.playContent()
            return .success
        }
        
        remoteCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pauseContent()
            return .success
        }
    }
}
