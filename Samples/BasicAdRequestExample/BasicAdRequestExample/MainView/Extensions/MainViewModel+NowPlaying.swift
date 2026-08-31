//
//  MainViewModel+NowPlaying.swift
//  BasicAdRequestExample
//
//  Created by George Mihoc on 14.01.2026.
//  Copyright © 2026 Inc, AdsWizz. All rights reserved.
//

import AdswizzExamplesCommon

extension MainViewModel: Isolatable {
    func updateNowPlaying(with data: NowPlayableStaticMetadata) {
        NowPlayingHelper.updateNowPlaying(
            with: data,
            onPlay: { [weak self] in self?.onMainActor { self?.playContent() } },
            onPause: { [weak self] in self?.onMainActor { self?.pauseContent() } }
        )
    }
}
