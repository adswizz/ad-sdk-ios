//
//  ViewController.swift
//  BasicAdStreamExample
//
//  Created by Teodor Cristea on 12/02/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import UIKit
import AdswizzSDK

class ViewController: UIViewController {
    @IBOutlet var extPlayerToggle: UISwitch!
    @IBOutlet var playStopButton: UIButton!
    @IBOutlet var pauseResumeButton: UIButton!
    @IBOutlet var status: UILabel!
    @IBOutlet var companionView: AdCompanionView!
    @IBOutlet var skipAdButton: UIButton!
    
    var model: Model = {
        return Model(capabilities: []) // no specific capabilities
    }()
    
    @objc func externalPlayerSwitchChanged(_ mySwitch: UISwitch) {
        model.isUsingExternalPlayer = mySwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ad streaming" + " - AdsWizz SDK v" + Bundle(for: AdswizzAdRequest.self).version
        
        companionView.delegate = self
        
        playStopButton.setTitle("Play stream", for: .normal)
        playStopButton.setTitle("Stop stream", for: .selected)
        
        pauseResumeButton.setTitle("Pause stream", for: .normal)
        pauseResumeButton.setTitle("Resume stream", for: .selected)

        skipAdButton.isSelected = true
        skipAdButton.isHidden = true
    }
}

extension ViewController {
    @IBAction func playStopStream(button: UIButton) {
        defer { button.isSelected = model.state == .playing }
        switch model.state {
        case .playing, .paused:
            model.stop()
            pauseResumeButton.isSelected = false
            extPlayerToggle?.isUserInteractionEnabled = true
        case .stopped:
            do {
                model.adBreakDelegate = self
                model.streamDelegate = self
                try model.play()
                extPlayerToggle?.isUserInteractionEnabled = false
            } catch {
                print("Failed to play ad stream. Reason = \(error)")
            }
        }
    }
    
    @IBAction func pauseResumeStream(button: UIButton) {
        if !model.isReadyToPlay {
            return
        }
        button.isSelected = !button.isSelected
        switch model.state {
        case .playing:
            model.pause()
        case .paused:
            model.resume()
        default:
            break
        }
    }
    
    @IBAction func skipAd(button: UIButton) {
        model.skipAd()
    }
}
