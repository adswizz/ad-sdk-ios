//
//  ViewController+ModelAdDelegate.swift
//  BasicVideoAdExample
//
//  Created by Teodor Cristea on 16/11/2020.
//

import Foundation
import AdswizzSDK

extension ViewController: ModelAdDelegate {
    func model(_ model: Model, didStartLoading adType: AdType) {
        if adType == .video {
            videoView.start()
            showVideoView()
            videoView.showSkipButton(false)
        }
    }
    
    func model(_ model: Model, didStartPlayback adType: AdType) {
        if adType == .video {
            videoView.stop()
            videoView.showSkipButton(true)
        } else {
            dismissVideoView()
        }
    }
    
    func model(_ model: Model, didEndPlayback adType: AdType) {
        if adType == .video {
            dismissVideoView()
            videoView.updateSkipButton(with: .initial)
        }
    }
    
    func model(_ model: Model, didComplete adType: AdType) {
    }
    
    func modelDidCompleteAllAds(_ model: Model) {
        handleStop()
        totalAdsDurationLabel.text = model.totalAdsDurationText
    }
    
    func model(_ model: Model, playHeadChanged playHead: TimeInterval, duration: TimeInterval) {
    }
    
    func model(_ model: Model, skipStateChanged state: SkipState) {
        skipState = state
        videoView.updateSkipButton(with: state)
    }
    
    func model(_ model: Model, adIndexChanged index: Int) {
        adCountLabel.text = model.adCountText
        totalAdsDurationLabel.text = model.totalAdsDurationText
    }
}

extension ViewController: ModelAdDatasource {
    func modelAdVideoViewProvider(_ model: Model) -> AdVideoView {
        return videoView.videoView
    }
}

private extension ViewController {
    func handleStop() {
        videoView.stop()
        actionButton.isSelected = false
        model.stop()
    }
}
