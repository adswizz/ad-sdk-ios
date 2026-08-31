//
//  ViewController+NowPlaying.swift
//  BasicAdRequestWatchExample
//
//  Created by Teodor Cristea on 05/03/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzExamplesCommon

extension ViewController: Isolatable {
    func updateNowPlaying(with data: NowPlayableStaticMetadata) {
        NowPlayingHelper.updateNowPlaying(
            with: data,
            onPlay: { [weak self] in self?.onMainActor { self?.playContent() } },
            onPause: { [weak self] in self?.onMainActor { self?.pauseContent() } }
        )
    }
}
