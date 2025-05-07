//
//  ViewController.swift
//  BasicDVRRequestExample
//
//  Created by Adrian Manolache on 07.07.2021.
//

import UIKit
import AdswizzSDK
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet var playStopButton: UIButton!
    @IBOutlet var pauseResumeButton: UIButton!
    @IBOutlet var externalPlayerToggle: UISwitch!
    var containerViewController: ContentViewController!
    
    var startLabel: UITextField! { return containerViewController.startLabel }
    var endLabel: UITextField! { return containerViewController.endLabel }
    var bufferLabel: UILabel! { return containerViewController.bufferLabel }
    
    var playFromTimestampButton: UIButton! { return containerViewController.playFromTimestampButton }
    var playFromTimestampTextField: UITextField! { return containerViewController.playFromTimestampTextField }
    var predefinedTimestamps: UIStackView! { return containerViewController.predefinedTimestamps }
        
    var dvrPlayButtons = [UIButton]()
    
    lazy var model: Model = {
        // The SDK doesn't query information about dvr support from a stream. To be able to perform DVR, the user must explicitly mark a stream as such by adding the .dvr capability to the adstreammanagersettings object
        // Note that the default stream URL does not support DVR, therefore you can pass your test stream URL when the Model is initialized.
        //e.g let model = Model(stremUrl: <your-stream-url> ,capabilities: [.dvr])
        let model = Model(capabilities: [.dvr])
        model.streamDelegate = self
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "DVR Streaming"
        
        dvrPlayButtons = predefinedTimestamps.subviews.compactMap { $0 as? UIButton }
        dvrPlayButtons += [playFromTimestampButton]
        
        //activate external player by default
        externalPlayerToggle.isOn = true
        externalPlayerSwitchChanged(externalPlayerToggle)
        
        //by default, hide the UI specific to DVR
        containerViewController.view.isHidden = true
    }
    
    @IBAction func playStopStream(button: UIButton) {
        switch model.state {
        case .playing, .paused:
            model.stop()
            resetDVRButtonsBackground()
            externalPlayerToggle.isUserInteractionEnabled = true
            containerViewController.view.isHidden = true
            playStopButton.setTitle("Play stream", for: .normal)
        case .stopped:
            do {
                try model.play()
                externalPlayerToggle.isUserInteractionEnabled = false
                playStopButton.setTitle("Stop stream", for: .normal)
                containerViewController.view.isHidden = false
            } catch {
                kLog.log("Failed to play ad stream. Reason = \(error)")
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
            pauseResumeButton.setTitle("Resume stream", for: .normal)
        case .paused:
            model.resume()
            pauseResumeButton.setTitle("Pause stream", for: .normal)
        default:
            break
        }
    }
    
    @IBAction func externalPlayerSwitchChanged(_ mySwitch: UISwitch) {
        model.isUsingExternalPlayer = mySwitch.isOn
    }
    
    private func updateUI(with metadata: AdStreamDVRMetadata?) {
        guard let metadata = metadata else { return }
        startLabel.text = "\(metadata.start)"
        endLabel.text = "\(metadata.end)"
        bufferLabel.text = "\(metadata.length)"
    }
    
    private func resetDVRButtonsBackground() {
        dvrPlayButtons.forEach {
            $0.backgroundColor = .systemBlue
        }
    }
    
    //get the reference to the embedded content (table) view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let connectContainerViewController = segue.destination as? ContentViewController, segue.identifier == "content" {
            connectContainerViewController.delegate = self
            containerViewController = connectContainerViewController
        }
    }
}

extension ViewController: ContentViewControllerDelegate {
    func content(_ contentViewController: ContentViewController, didTapPlayFromTimestamp button: UIButton) {
        resetDVRButtonsBackground()
        button.backgroundColor = .systemGreen
        
        let timestamp = Int64(playFromTimestampTextField.text ?? "") ?? 0
        do {
            try model.play(with: NSNumber(value: timestamp))
        } catch {
            kLog.log("Error \(error) playing stream at DVR timestamp \(timestamp)")
        }
    }
    
    func content(_ contentViewController: ContentViewController, didTapPlayFromPredefinedTimestamp button: UIButton) {
        let index = button.tag
        resetDVRButtonsBackground()
        button.backgroundColor = .systemGreen
        
        guard let metadata = model.dvrMetadata else {
            kLog.log("DVR metadata is not available")
            return
        }
        let start = metadata.start
        let end = metadata.end
        let interval = (end - start) / 4 * index
        let timestamp = Int(start + interval)
        playFromTimestampTextField.text = "\(timestamp)"
        kLog.log("Playing stream with DVR from timestamp = \(timestamp)")
        do {
            try model.play(with: NSNumber(value: timestamp))
        } catch {
            kLog.log("Error \(error) playing stream at DVR timestamp \(timestamp)")
        }
    }
}

extension ViewController: ModelStreamingDelegate {
    func modelDidStartStreaming(_ model: Model) {}
    
    func modelDidStopStreaming(_ model: Model) {}
    
    func modelDidPauseStreaming(_ model: Model) {}
    
    func modelDidResumeStreaming(_ model: Model) {}
    
    func model(_ model: Model, didReceive dvrMetadata: AdStreamDVRMetadata?) {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(with: dvrMetadata)
        }
    }
    
}
