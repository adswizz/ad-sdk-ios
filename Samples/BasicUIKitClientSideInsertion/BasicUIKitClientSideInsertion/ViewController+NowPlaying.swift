//
//  ViewController+NowPlaying.swift
//  BasicUIKitClientSideInsertion
//
//  Created by George Mihoc on 16.06.2026.
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
