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
    
    var currentDuration: TimeInterval = 0 // the total duration reported by podcastManager once play starts
    var isPlaying = false
    var isPaused = false
    var podcastList = [PodcastListItem]()
    var toggles = [UISwitch]()
    var buttons = [UIButton]()
    var contentViews = [UIView]()
    var progressLabels = [UILabel]()
    
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
        
        createUI()
    }
    
    func playPodcast() {
        currentPodcastManager()?.play()
    }

    func currentPodcastManager() -> PodcastListItem? {
        let tagOn = toggles.first { $0.isOn }?.tag ?? 0
        return podcastList.first { $0.id == tagOn }
    }
    
    func createUI() {
        title = "Podcast"

        playPauseButtonsStackView.addArrangedSubview(playStopButton)
        playPauseButtonsStackView.addArrangedSubview(pauseResumeButton)
        view.addSubview(verticalStackView)
        verticalStackView.addSubview(playPauseButtonsStackView)
        verticalStackView.addSubview(seekBar)
        verticalStackView.addSubview(podcastItemsStackView)
        verticalStackView.addSubview(companionView)
        verticalStackView.addSubview(skipAdButtonView)
        seekBar.delegate = self
        
        podcastItemsStackView.spacing = 0
        podcastList.forEach {
            podcastItemsStackView.addArrangedSubview(podcastSingleItemStackView(from: $0))
        }
 
        NSLayoutConstraint.activate([
            verticalStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0),
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            verticalStackView.heightAnchor.constraint(equalToConstant: 700),

            playPauseButtonsStackView.heightAnchor.constraint(equalToConstant: 45),
            playPauseButtonsStackView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
            playPauseButtonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButtonsStackView.bottomAnchor.constraint(equalTo: verticalStackView.bottomAnchor),

            seekBar.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
            seekBar.heightAnchor.constraint(equalToConstant: 50),
            seekBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            seekBar.bottomAnchor.constraint(equalTo: skipAdButtonView.topAnchor, constant: 0),
            
            podcastItemsStackView.topAnchor.constraint(equalTo: companionView.bottomAnchor),
            podcastItemsStackView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
            podcastItemsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            podcastItemsStackView.bottomAnchor.constraint(equalTo: seekBar.topAnchor, constant: -20),
            podcastItemsStackView.heightAnchor.constraint(equalToConstant: 300),
            
            companionView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
            companionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            companionView.topAnchor.constraint(equalTo: verticalStackView.topAnchor),
            
            skipAdButtonView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
            skipAdButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipAdButtonView.heightAnchor.constraint(equalToConstant: 50),
            skipAdButtonView.bottomAnchor.constraint(equalTo: playPauseButtonsStackView.topAnchor)
        ])
        toggles.first!.isOn = true
        switchChanged(toggles.first!)
    }
    
    func styledButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont(name: "Arial", size: 14.0)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.black, for: .selected)
        return button
    }
    
    lazy var seekBar: SeekBarView = {
        //Seek bar
        let seekBar = SeekBarView()
        seekBar.translatesAutoresizingMaskIntoConstraints = false
        return seekBar
    }()
    
    func podcastSingleItemStackView(from podcastItem: PodcastListItem) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = podcastItem.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Arial", size: 14)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .lightGray
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = UIStackView.spacingUseSystem
        
        let switchToggle = UISwitch()
        switchToggle.translatesAutoresizingMaskIntoConstraints = false
        switchToggle.isOn = false
        toggles.append(switchToggle)
        
        let switchView = UIView()
        switchView.backgroundColor = .white
        switchView.layer.cornerRadius = 12
        switchView.layer.masksToBounds = true
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.addSubview(switchToggle)
        contentView.addSubview(switchView)
        
        let urlLabel = UILabel()
        urlLabel.textAlignment = .right
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        urlLabel.text = podcastItem.url.lastPathComponent
        urlLabel.numberOfLines = 1
        urlLabel.lineBreakMode = .byTruncatingMiddle
        urlLabel.font = UIFont(name: "Arial", size: 12.0)
        
        let progressLabel = UILabel()
        progressLabel.tag = podcastItem.id
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.text = "downloading 0%"
        progressLabel.textAlignment = .right
        progressLabel.numberOfLines = 1
        progressLabel.lineBreakMode = .byTruncatingMiddle
        progressLabel.font = UIFont(name: "Arial", size: 11.0)
        progressLabel.isHidden = true
        progressLabels.append(progressLabel)
        
        let downloadButton = styledButton()
        downloadButton.tag = podcastItem.id
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.setTitle("Download", for: UIControl.State.normal)
        downloadButton.setTitle("Remove", for: UIControl.State.selected)
        downloadButton.setTitleColor(.white, for: .selected)
        downloadButton.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
        buttons.append(downloadButton)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.addSubview(downloadButton)

        let podcastContentView = UIView()
        podcastContentView.backgroundColor = .white
        podcastContentView.layer.cornerRadius = 12
        podcastContentView.layer.masksToBounds = true
        podcastContentView.translatesAutoresizingMaskIntoConstraints = false
        podcastContentView.addSubview(urlLabel)
        podcastContentView.addSubview(progressLabel)
        podcastContentView.addSubview(buttonsView)
        podcastContentView.tag = podcastItem.id
        
        contentView.addSubview(podcastContentView)
        stack.addSubview(titleLabel)
        stack.addSubview(contentView)
        
        contentViews.append(podcastContentView)

        switchToggle.tag = podcastItem.id
        switchToggle.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        NSLayoutConstraint.activate([
            switchToggle.centerXAnchor.constraint(equalTo: switchView.centerXAnchor),
            switchToggle.centerYAnchor.constraint(equalTo: switchView.centerYAnchor),
            
            switchView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0),
            switchView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.0),
            switchView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6.0),
            switchView.widthAnchor.constraint(equalToConstant: 60),
            
            podcastContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0),
            podcastContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.0),
            podcastContentView.leadingAnchor.constraint(equalTo: switchView.trailingAnchor, constant: 6.0),
            podcastContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6.0),
            
            titleLabel.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 10.0),
            titleLabel.topAnchor.constraint(equalTo: stack.topAnchor, constant: 10.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 22.0),
            
            contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: stack.bottomAnchor),
            
            urlLabel.topAnchor.constraint(equalTo: podcastContentView.topAnchor),
            urlLabel.leadingAnchor.constraint(equalTo: podcastContentView.leadingAnchor, constant: 6),
            urlLabel.trailingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: -10),
            urlLabel.bottomAnchor.constraint(equalTo: podcastContentView.bottomAnchor),
            
            progressLabel.trailingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: -10),
            progressLabel.heightAnchor.constraint(equalToConstant: 16.0),
            progressLabel.bottomAnchor.constraint(equalTo: podcastContentView.bottomAnchor),
            
            buttonsView.topAnchor.constraint(equalTo: podcastContentView.topAnchor),
            buttonsView.widthAnchor.constraint(equalToConstant: 100),
            buttonsView.trailingAnchor.constraint(equalTo: podcastContentView.trailingAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: podcastContentView.bottomAnchor),
            
            downloadButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
            downloadButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor,constant: -5),
            downloadButton.centerYAnchor.constraint(equalTo: buttonsView.centerYAnchor),
            downloadButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        return stack
    }
    lazy var podcastItemsStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = UIStackView.spacingUseSystem
        return stack
    }()
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = UIStackView.spacingUseSystem
        return stack
    }()
    lazy var playPauseButtonsStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = UIStackView.spacingUseSystem
        return stack
    }()
    lazy var skipAdButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(), size: 16)
        button.setTitle("Skip ad", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(skipAdPressed(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var skipAdButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skipAdButton)
        NSLayoutConstraint.activate([
            skipAdButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipAdButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            skipAdButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        return view
    }()
    lazy var playStopButton: UIButton = {
        let button = styledButton()
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(), size: 16)
        button.setTitle("Play podcast", for: .normal)
        button.setTitle("Stop podcast", for: .selected)
        button.setTitleColor(.white, for: .selected)
        button.addTarget(self, action: #selector(playStopStream(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var pauseResumeButton: UIButton = {
        let button = styledButton()
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(), size: 16)
        button.setTitle("Pause podcast", for: .normal)
        button.setTitle("Resume podcast", for: .selected)
        button.setTitleColor(.white, for: .selected)
        button.addTarget(self, action: #selector(pauseResumeStream(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var companionView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Companion view"
        let companionView = AdCompanionView(frame: .zero)
        companionView.delegate = self
        companionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        containerView.addSubview(companionView)
        NSLayoutConstraint.activate([
            companionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            companionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            companionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            companionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        containerView.backgroundColor = UIColor(displayP3Red: 145.0 / 255.0, green: 25.0 / 255.0, blue: 111.0 / 255.0, alpha: 1.0)
        return containerView
    }()
    
    @objc func downloadButtonPressed(_ button: UIButton) {
        currentPodcastManager()?.downloadPressed()
    }
    
    @objc func switchChanged(_ mySwitch: UISwitch) {
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
        currentPodcastManager()?.stop()
        isPlaying = false
        isPaused = false
        playStopButton.isSelected = isPlaying
        pauseResumeButton.isSelected = isPaused
        updateSeekBarLabels(0, 0)
    }
    
    @objc func skipAdPressed(button: UIButton) {
        adBreakManager?.skipAd()
    }
    
    @objc func playStopStream(button: UIButton) {
        if isPlaying {
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
    
    @objc func pauseResumeStream(button: UIButton) {
        if isPaused {
            currentPodcastManager()?.resume()
        } else {
            currentPodcastManager()?.pause()
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
