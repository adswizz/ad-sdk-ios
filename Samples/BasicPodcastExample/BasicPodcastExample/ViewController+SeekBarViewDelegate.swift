//
//  ViewController+SeekBarViewDelegate.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 14.02.2022.
//

import Foundation
import AVFoundation

extension ViewController: SeekBarViewDelegate {
    func seekBarView(_ view: SeekBarView, didChangeTracking value: Bool, at sliderValue: Float) {
        if value {
            didStartSeeking(at: sliderValue)
        } else {
            didEndSeeking(at: sliderValue)
        }
    }
    
    func seekBarView(_ view: SeekBarView, didChangeSlider value: Float) {
        didChangeSeeking(at: value)
    }
    
    func didChangeSeeking(at sliderValue: Float) {
        updateSeekBarLabels(currentDuration * Double(sliderValue), currentDuration)
    }
    
    func didStartSeeking(at sliderValue: Float) {
    }
    
    func didEndSeeking(at sliderValue: Float) {
        seek(to: sliderValue * Float(currentDuration))
    }

    func seek(to: Float) {
        if externalPlayerSwitch.isOn {
            let seekTime = CMTime(value: Int64(to), timescale: 1)
            currentPodcastManager()?.externalPlayer.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { finished in
                if finished {
                    //finished the seek operation
                }
            }
        } else {
            currentPodcastManager()?.seek(to: to)
        }
    }
    
    func updateSeekBarLabels(_ playhead: TimeInterval, _ duration: TimeInterval) {
        var secondsText = String(format: "%02d", Int(duration) % 60)
        var minutesText = String(format: "%02d", Int(duration) / 60)
        seekBarView.lengthLabel.text = "\(minutesText):\(secondsText)"
        
        secondsText = String(format: "%02d", Int(playhead) % 60)
        minutesText = String(format: "%02d", Int(playhead) / 60)
        seekBarView.startLabel.text = "\(minutesText):\(secondsText)"
        
        seekBarView.slider.setValue(Float(playhead/duration), animated: false)
    }
}
