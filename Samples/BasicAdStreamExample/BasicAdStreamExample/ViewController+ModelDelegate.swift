//
//  ViewController+ModelDelegate.swift
//  BasicAdStreamExample
//
//  Created by Teodor Cristea on 12/02/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import UIKit
import AdswizzSDK

extension ViewController: ModelStreamingDelegate {
    func modelDidStartStreaming(_ model: Model) {
        setStatus(with: "Playing stream...", fading: true)
    }
    
    func modelDidStopStreaming(_ model: Model) {
        setStatus(with: "Stream stopped")
    }
    
    func modelDidPauseStreaming(_ model: Model) {
        setStatus(with: "Stream paused")
    }
    
    func modelDidResumeStreaming(_ model: Model) {
        setStatus(with: "Playing stream...", fading: true)
    }
    
    func model(_ model: Model, didReceive dvrMetadata: AdStreamDVRMetadata?) {
        
    }
}

extension ViewController: ModelAdBreakDelegate {
    func modelDidStartAdBreak(_ model: Model) {
        setStatus(with: "Ad break detected! Playing ad(s)...")
        enableSkipButton(enable: true)
    }
    
    func modelDidEndAdBreak(_ model: Model) {
        setStatus(with: "Ad break ended!")
        enableSkipButton(enable: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.setStatus(with: "Playing stream...", fading: true)
        }
    }
}

extension ViewController {
    func setStatus(with text: String, fading enabled: Bool = false) {
        status.text = text
        if enabled {
            status.alpha = 0
        } else {
            status.layer.removeAllAnimations()
        }
        UIView.animate(withDuration: enabled ? 0.5 : 0.0,
                       delay: 0,
                       options: enabled ? [.autoreverse, .repeat] : [.beginFromCurrentState] , animations: {
                        self.status.alpha = 1
        }) { finished in }

    }
}

extension ViewController {
    func enableSkipButton(enable: Bool, animated: Bool = true) {
        if (!skipAdButton.isHidden && enable) || (skipAdButton.isHidden && !enable) {
            return
        }
        UIView.animate(withDuration: animated ? 0.3 : 0.0) { [weak self] in
            self?.skipAdButton.isHidden = !enable
        }
    }
}
