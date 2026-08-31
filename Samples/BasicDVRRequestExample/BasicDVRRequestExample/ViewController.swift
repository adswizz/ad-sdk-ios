//
//  ViewController.swift
//  BasicDVRRequestExample
//
//  Created by Adrian Manolache on 07.07.2021.
//

import UIKit
import AdswizzSDK
import AdswizzExamplesCommon
import Combine

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

    private let viewModel = DVRViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DVR Streaming"
        
        dvrPlayButtons = predefinedTimestamps.subviews.compactMap { $0 as? UIButton }
        dvrPlayButtons += [playFromTimestampButton]
        
        //activate external player by default
        externalPlayerToggle.isOn = true
        externalPlayerSwitchChanged(externalPlayerToggle)
        
        //by default, hide the UI specific to DVR
        containerViewController.view.isHidden = true

        // Observe DVR metadata changes via Combine
        viewModel.$dvrMetadata
            .receive(on: DispatchQueue.main)
            .sink { [weak self] metadata in
                self?.updateUI(with: metadata)
            }
            .store(in: &cancellables)
    }
    
    @IBAction func playStopStream(button: UIButton) {
        if viewModel.isPlaying || viewModel.isPaused {
            viewModel.stop()
            resetDVRButtonsBackground()
            externalPlayerToggle.isUserInteractionEnabled = true
            containerViewController.view.isHidden = true
            playStopButton.setTitle("Play stream", for: .normal)
        } else {
            viewModel.play()
            externalPlayerToggle.isUserInteractionEnabled = false
            playStopButton.setTitle("Stop stream", for: .normal)
            containerViewController.view.isHidden = false
        }
    }
    
    @IBAction func pauseResumeStream(button: UIButton) {
        guard viewModel.isPlaying || viewModel.isPaused else { return }
        button.isSelected = !button.isSelected
        if viewModel.isPaused {
            viewModel.resume()
            pauseResumeButton.setTitle("Pause stream", for: .normal)
        } else {
            viewModel.pause()
            pauseResumeButton.setTitle("Resume stream", for: .normal)
        }
    }
    
    @IBAction func externalPlayerSwitchChanged(_ mySwitch: UISwitch) {
        viewModel.useExternalPlayer = mySwitch.isOn
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
            try viewModel.playFromTimestamp(NSNumber(value: timestamp))
        } catch {
            kLog.log("Error \(error) playing stream at DVR timestamp \(timestamp)")
        }
    }
    
    func content(_ contentViewController: ContentViewController, didTapPlayFromPredefinedTimestamp button: UIButton) {
        let index = button.tag
        resetDVRButtonsBackground()
        button.backgroundColor = .systemGreen
        
        guard let metadata = viewModel.dvrMetadata else {
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
            try viewModel.playFromTimestamp(NSNumber(value: timestamp))
        } catch {
            kLog.log("Error \(error) playing stream at DVR timestamp \(timestamp)")
        }
    }
}
