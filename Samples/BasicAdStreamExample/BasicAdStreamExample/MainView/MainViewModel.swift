//
//  MainViewModel.swift
//  BasicAdStreamExample
//
//  Created by George Mihoc on 15.01.2026.
//  Copyright © 2026 Inc, AdsWizz. All rights reserved.
//

import AdswizzSDK
import AdswizzExamplesCommon
import SwiftUI

final class MainViewModel: ServerSideAdViewModel {

    override var adServer: String { "demo.deliveryengine.adswizz.com" }
    override var streamUrl: URL? { URL(string: "https://streaming.sdk.eks.devel.adswizz.com/shakeDemo") }

    override init() {
        super.init()
        externalPlayer = ExternalMediaPlayer()
    }
    
    func didTapPlayStop() {
        if isPlaying || isPaused {
            stop()
        } else {
            play()
        }
    }
    
    func didTapPauseResume() {
        guard isPlaying || isPaused else { return }
        isPaused ? resume() : pause()
    }

    func didTapSkipAd() {
        skipCurrentAd()
    }
}
