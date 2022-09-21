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
    @IBOutlet var startLabel: UIStackView!
    @IBOutlet var endLabel: UIStackView!
    @IBOutlet var bufferLabel: UIStackView!
    @IBOutlet var dvrStackView: UIStackView!
    @IBOutlet var playFromTimestampStackView: UIStackView!
    @IBOutlet var showsStackView: UIStackView!
    
    var streamManager: AdswizzAdStreamManager?
    let url = URL(string: "http://sdk.mobile.streaming.adswizz.com:8500/kissFM/playlist.m3u8")
    let adServer = "demo.deliveryengine.adswizz.com"
    var dvrPlayButtons = [UIButton]()
    let kViewTag = 101
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "DVR Streaming"
        isPlaying = false
        
        dvrPlayButtons = showsStackView.subviews.compactMap { $0 as? UIButton }
        dvrPlayButtons += playFromTimestampStackView.subviews.compactMap { $0 as? UIButton }
        
        do {
            try createStreamManager()
        } catch {
            print("Error creating stream manager \(error)")
        }
    }
    
    func createStreamManager() throws {
        // Create a new stream manager
        streamManager = try AdswizzAdStreamManager.Builder()
            .with(adServer: adServer)               //Mandatory
            .with(httpProtocol: .https)             //Optional: defaults to https protocol for the ad server
            .with(companionZones: "")               //Optional: companion zone provided by a PIM
            .build()
        streamManager?.delegate = self
        
        // The SDK doesn't query information about dvr support from a stream. To be able to perform DVR, the user must explicitly mark a stream as such by adding the .dvr capability to the adstreammanagersettings object
        let settings = AdStreamManagerSettings()
        settings.addCapability(.dvr)
        streamManager?.adStreamManagerSettings = settings
    }
    
    @IBAction func playStopStream(button: UIButton) {
        guard let url = url else { return }
    
        if isPlaying {
            resetDVRButtonsBackground()
            streamManager?.stop()
        } else {
            try? streamManager?.play(with: url)
        }
        isPlaying = !isPlaying
    }
    
    @IBAction func pauseResumeStream(button: UIButton) {
        if isPaused {
            streamManager?.resume()
        } else {
            streamManager?.pause()
        }
        isPaused = !isPaused
    }
    
    private func updateUI(with metadata: DVRMetadata?) {
        guard let metadata = metadata else { return }
        (startLabel.viewWithTag(kViewTag) as? UITextField)?.text = "\(metadata.start)"
        (endLabel.viewWithTag(kViewTag) as? UITextField)?.text = "\(metadata.end)"
        (bufferLabel.viewWithTag(kViewTag) as? UILabel)?.text = "\(metadata.length)"
    }
    var showDVRUI: Bool = false {
        didSet {
            dvrStackView.isHidden = !showDVRUI
        }
    }
    var dvrMetadata: DVRMetadata? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.updateUI(with: self?.dvrMetadata)
            }
        }
    }
    var isPlaying: Bool = false {
        didSet {
            playStopButton.setTitle((!isPlaying ? "Play" : "Stop") + " stream", for: .normal)
            if !isPlaying {
                isPaused = false
            }
            showDVRUI = isPlaying
        }
    }
    var isPaused: Bool = false {
        didSet {
            pauseResumeButton.setTitle((!isPaused ? "Pause" : "Resume") + " stream", for: .normal)
        }
    }

    @IBAction func playFromTimestamp(button: UIButton) {
        resetDVRButtonsBackground()
        button.backgroundColor = .systemGreen
        
        guard let url = url else { return }
        let timestamp = Int((playFromTimestampStackView.viewWithTag(kViewTag) as? UITextField)?.text ?? "") ?? 0
        streamManager?.stop()
        do {
            try streamManager?.play(with: url, timestamp: NSNumber(value: timestamp))
        } catch {
            print("Error \(error) playing stream \(url) with dvr \(timestamp)")
        }
    }
    
    private func resetDVRButtonsBackground() {
        dvrPlayButtons.forEach {
            $0.backgroundColor = .systemBlue
        }
    }
    
    @IBAction func playShow(button: UIButton) {
        let index = button.tag
        resetDVRButtonsBackground()
        button.backgroundColor = .systemGreen
        
        guard let url = url, let metadata = dvrMetadata else { return }
        let start = metadata.start
        let end = metadata.end
        let interval = (end - start) / 4 * index
        let timestamp = Int(start + interval)
        (playFromTimestampStackView.viewWithTag(kViewTag) as? UITextField)?.text = "\(timestamp)"
        print("DVR FROM timestamp=\(timestamp)")
        streamManager?.stop()
        do {
            try streamManager?.play(with: url, timestamp: NSNumber(value: timestamp))
        } catch {
            print("Error \(error) playing stream \(url) with dvr \(timestamp)")
        }
    }
}

extension ViewController: AdStreamManagerDelegate {
    func adStreamManager(_ adstreamManager: AdStreamManager, didReceive dvrMetadata: DVRMetadata?) {
        self.dvrMetadata = dvrMetadata
        print("dvrMetadata=\(String(describing: dvrMetadata))")
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL) {
        
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakStarted manager: AdManager) {
        
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, stateChanged state: MediaPlayerStatus) {
        
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakEnded manager: AdManager) {
        
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, metadataChanged metadata: [AVMetadataItem]) {
        
    }
    
    func adStreamManagerWillReconnect(_ adstreamManager: AdStreamManager) {
        
    }
    
    func adStreamManagerPlayerShouldPause(_ adstreamManager: AdStreamManager) {
        
    }
    
    func adStreamManagerPlayerShouldResume(_ adstreamManager: AdStreamManager) {
        
    }
}
