//
//  ViewController+SeekBarViewDelegate.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 14.02.2022.
//

import Foundation

extension ViewController: SeekBarViewDelegate {
    func seekBarView(_ view: SeekBarView, didChangeSlider value: Float) {
        print("seekBarView value=\(value)")
        seek(to: value * Float(currentDuration))
    }
    
    func seek(to: Float) {
        currentPodcastManager()?.seek(to: to)
    }
    
    func updateSeekBarLabels(_ playhead: TimeInterval, _ duration: TimeInterval) {
        guard !seekBar.slider.isTracking else { return }
        
        var secondsText = String(format: "%02d", Int(duration) % 60)
        var minutesText = String(format: "%02d", Int(duration) / 60)
        seekBar.lengthLabel.text = "\(minutesText):\(secondsText)"
        
        secondsText = String(format: "%02d", Int(playhead) % 60)
        minutesText = String(format: "%02d", Int(playhead) / 60)
        seekBar.startLabel.text = "\(minutesText):\(secondsText)"
        
        seekBar.slider.setValue(Float(playhead/duration), animated: false)
    }
}
