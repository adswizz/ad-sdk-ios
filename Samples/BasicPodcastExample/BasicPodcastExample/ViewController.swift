//
//  ViewController.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 10.02.2022.
//

import UIKit
import AdswizzSDK
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var playStopButton: UIButton!
    @IBOutlet var pauseResumeButton: UIButton!
    @IBOutlet var seekBarView: SeekBarView!
  
    var currentDuration: TimeInterval = 0 // the total duration reported by podcastManager once play starts
    var isPlaying = false
    var isPaused = false
    var podcastList = [PodcastListItem]()
    @IBOutlet var toggles: [UISwitch]!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var contentViews: [UIView]!
    @IBOutlet var progressLabels: [UILabel]!
    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet var companionView: AdCompanionView!
    @IBOutlet var companionViewLabel: UILabel!
    @IBOutlet var externalPlayerSwitch: UISwitch!
    
    var externalPlayer = ExternalMediaPlayer()
    
    var adBreakManager: AdManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        podcastList = [
            PodcastListItem(title: "Podcast 1", url: URL(string: "http://sdk.mobile.streaming.adswizz.com:8501/podcast_RAD_QueenBohemian.mp3")!),
            PodcastListItem(title: "Podcast 2", url: URL(string: "http://sdk.mobile.streaming.adswizz.com:8501/podcast_RAD_sampleFile.mp3")!),
            PodcastListItem(title: "Podcast 3", url: URL(string: "http://sdk.mobile.streaming.adswizz.com:8501/podcast_RAD_muchosEvents.mp3")!)
        ]
        podcastList.forEach {
            $0.delegate = self
            $0.podcastItemDelegate = self
        }
        
        fillUI(with: podcastList)
        
        companionView.delegate = self
        
        seekBarView.delegate = self
        toggles.first!.isOn = true
        switchChanged(toggles.first!)
        
        playStopButton.setTitle("Play podcast", for: .normal)
        playStopButton.setTitle("Stop podcast", for: .selected)
        
        pauseResumeButton.setTitle("Pause podcast", for: .normal)
        pauseResumeButton.setTitle("Resume podcast", for: .selected)
    }
    
    private func fillUI(with list: [PodcastListItem]) {
        for i in 0 ..< list.count {
            let id = list[i].id
            setTag(to: id, index: i)
            
            let button = buttons[i]
            button.setTitle("Remove", for: UIControl.State.selected)
            
            let label = titleLabels[i]
            label.text = list[i].url.lastPathComponent
        }
    }
    
    private func setTag(to id: Int, index: Int) {
        toggles[index].tag = id
        buttons[index].tag = id
        contentViews[index].tag = id
        progressLabels[index].tag = id
    }

    func playPodcast() {
        currentPodcastManager()?.play(shouldUseCustomPlayer: externalPlayerSwitch.isOn)
    }

    func currentPodcastManager() -> PodcastListItem? {
        let tagOn = toggles.first { $0.isOn }?.tag ?? 0
        return podcastList.first { $0.id == tagOn }
    }

    @IBAction func downloadButtonPressed(_ button: UIButton) {
        currentPodcastManager()?.downloadPressed()
    }
    
    @IBAction func switchChanged(_ mySwitch: UISwitch) {
        let hasNewSelection = mySwitch.isOn
        
        guard hasNewSelection else {
            mySwitch.isOn = true
            return
        }
        
        stopCurrentPodcast()
        
        toggles.forEach { $0.isOn = false }
        mySwitch.isOn = true
        podcastList.forEach {
            $0.stop()
            deselectPodcastUI(id: $0.id)
        }

        for podcast in podcastList {
            if podcast.id == mySwitch.tag {
                selectPodcastUI(id: podcast.id)
            }
        }
    }
    
    private func selectPodcastUI(id: Int) {
        let contentView = contentViews.first { $0.tag == id }
        contentView?.backgroundColor = .white
        contentView?.isUserInteractionEnabled = true
        let button = buttons.first { $0.tag == id }
        button?.backgroundColor = .systemBlue
    }
    
    private func deselectPodcastUI(id: Int) {
        let contentView = contentViews.first { $0.tag == id }
        let color: CGFloat = 0.9
        contentView?.backgroundColor = UIColor(displayP3Red: color, green: color, blue: color, alpha: 1.0)
        contentView?.isUserInteractionEnabled = false
        let button = buttons.first { $0.tag == id }
        button?.backgroundColor = .gray
    }
    
    func stopCurrentPodcast() {
        if externalPlayerSwitch.isOn {
            currentPodcastManager()?.stopExternalPlayer()
        }
        currentPodcastManager()?.stop()
        isPlaying = false
        isPaused = false
        playStopButton.isSelected = isPlaying
        pauseResumeButton.isSelected = isPaused
        updateSeekBarLabels(0, 0)
    }
    
    @IBAction func skipAdPressed(button: UIButton) {
        adBreakManager?.skipAd()
    }
    
    @IBAction func playStopStream(button: UIButton) {
        if isPlaying {
            if externalPlayerSwitch.isOn {
                currentPodcastManager()?.stopExternalPlayer()
            }
            currentPodcastManager()?.stop()
            updateSeekBarLabels(0, 0)
        } else {
            playPodcast()
        }
        
        isPlaying = !isPlaying
        isPaused = false
        playStopButton.isSelected = isPlaying
        pauseResumeButton.isSelected = isPaused
    }
    
    @IBAction func pauseResumeStream(button: UIButton) {
        if isPaused {
            if externalPlayerSwitch.isOn {
                currentPodcastManager()?.playExternalPlayer()
            } else {
                currentPodcastManager()?.resume()
            }
        } else {
            if externalPlayerSwitch.isOn {
                currentPodcastManager()?.pauseExternalPlayer()
            } else {
                currentPodcastManager()?.pause()
            }
        }
        isPaused = !isPaused
        pauseResumeButton.isSelected = isPaused
    }
    
    func playContent() {
        
    }
    
    func pauseContent() {
        
    }
}

extension ViewController: PodcastListItemDelegate {
    func updatedDownloadProgress(id: Int, percent: Float) {
        onMain { [weak self] in
            print("Downloading \(Int(percent*100.0))%")
            let progressLabel = self?.progressLabels.first { $0.tag == id }
            progressLabel?.text = "Downloading \(Int(percent*100.0))%"
        }
    }
    
    func startedDownload(id: Int) {
        buttons.first { $0.tag == id }?.isSelected = true
        let progressLabel = progressLabels.first { $0.tag == id }
        progressLabel?.isHidden = false
        progressLabel?.text = "Downloading 0%"
    }
    
    func stoppedDownload(id: Int) {
        buttons.first { $0.tag == id }?.isSelected = false
        finishedDownload(id: id)
    }
    
    func finishedDownload(id: Int) {
        onMain { [weak self] in
            self?.progressLabels.first { $0.tag == id }?.isHidden = true
        }
    }
    
    func onMain(_ callback: @escaping () -> () ) {
        DispatchQueue.main.async {
            callback()
        }
    }
}
