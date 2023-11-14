//
//  PlayerViewController.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 29.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import UIKit
import AdswizzSDK

protocol PlayerViewControllerDelegate: AnyObject {
    func playerViewController(_ playerViewController: PlayerViewController, shouldDismiss animated: Bool)
}

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var companionContainerView: UIView!
    @IBOutlet weak var companionView: AdCompanionView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var descriptionStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var mediaStackView: UIStackView!
    @IBOutlet weak var mediaPlayButton: UIButton!
    @IBOutlet weak var mediaSeekBackwardButton: UIButton!
    @IBOutlet weak var mediaSeekForwardButton: UIButton!
    @IBOutlet weak var seekBar: SeekBarView!
    weak var delegate: PlayerViewControllerDelegate?
    var podcast: PodcastConfig.Podcast?
    
    /// Internal.
    var model: AppModel {
        return AppModelInstance
    }
    var state: Playlist.State {
        guard let currentPodcast = model.playingPodcast, podcast?.matches(podcast: currentPodcast) ?? false else {
            return .stopped
        }
        return model.currentState
    }
    var currentDuration: TimeInterval = 0 // the total duration reported once play starts
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companionView.delegate = self
        seekBar.delegate = self
        mediaSeekBackwardButton.addTarget(self, action: #selector(seekBackward), for: .touchUpInside)
        mediaPlayButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        mediaSeekForwardButton.addTarget(self, action: #selector(seekForward), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(dismissSelf))
        configure()
    }
    
    @objc func dismissSelf() {
        delegate?.playerViewController(self, shouldDismiss: true)
        model.remove(listener: self)
    }
    
    @objc func play() {
        guard let podcast = self.podcast else {
            return
        }
        switch state {
        case .starting:
            return
        case .started:
            model.pause()
        case .paused:
            model.resume()
        case .stopping, .stopped:
            model.play(from: podcast)
        }
    }
    
    @objc func seekForward() {
        guard let currentPodcast = self.podcast,
              let playingPodcast = model.playingPodcast,
              currentPodcast.matches(podcast: playingPodcast) else {
            return
        }
        model.seek(by: 10) { [weak self] in
            if self?.state == .paused {
                self?.model.resume()
            }
        }
    }

    @objc func seekBackward() {
        guard let currentPodcast = self.podcast,
              let playingPodcast = model.playingPodcast,
              currentPodcast.matches(podcast: playingPodcast) else {
            return
        }
        model.seek(by: -10) { [weak self] in
            if self?.state == .paused {
                self?.model.resume()
            }
        }
    }

    private func configure() {
        model.add(listener: self)
        guard let currentPodcast = self.podcast else {
            return
        }
        var state: Playlist.State = .stopped
        var hideCompanionView = true
        if let playingPodcast = model.playingPodcast {
            if currentPodcast.matches(podcast: playingPodcast) {
                state = model.currentState
                hideCompanionView = false
            }
        } else {
            hideCompanionView = false
        }
        companionView.isHidden = hideCompanionView
        appModel(model, stateWillChange: state, for: currentPodcast)
        
        titleLabel.text = podcast?.title
        authorLabel.text = podcast?.author
    }
}

extension PlayerViewController: AppModelListenerDelegate {
    func appModel(_ appModel: AppModelProtocol, stateWillChange state: Playlist.State, for podcast: PodcastConfig.Podcast) {
        guard let currentPodcast = self.podcast, currentPodcast.matches(podcast: podcast) else {
            return
        }
        switch state {
        case .starting:
            // loading
            break
        case .started:
            // playing
            mediaPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            break
        case .paused:
            // paused
            mediaPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            break
        case .stopping, .stopped:
            // finished
            break
        }
    }
    
    func appModel(_ appModel: AppModelProtocol, playheadChanged playhead: TimeInterval, duration: TimeInterval, for podcast: PodcastConfig.Podcast) {
        guard let currentPodcast = self.podcast, currentPodcast.matches(podcast: podcast) else {
            return
        }
        currentDuration = duration
        seekBar.updateSeekBarLabels(playhead, currentDuration)
    }
    
    func appModel(_ appModel: AppModelProtocol, didEncounterError error: Error, for podcast: PodcastConfig.Podcast) {
        guard let currentPodcast = self.podcast, currentPodcast.matches(podcast: podcast) else {
            return
        }
    }
    
    func appModel(_ appModel: AppModelProtocol, didStartPlaying ad: AdData, withCompanion: Bool) {
        guard let currentPodcast = self.podcast,
              let playingPodcast = model.playingPodcast,
              currentPodcast.matches(podcast: playingPodcast) else {
            return
        }
        if withCompanion {
            artworkImageView.isHidden = true
            companionContainerView.isHidden = false
        }
    }
    
    func appModel(_ appModel: AppModelProtocol, didEndPlaying ad: AdData, withCompanion: Bool) {
    }
}

extension PlayerViewController: SeekBarViewDelegate {
    func seekBarView(_ view: SeekBarView, didChangeTracking value: Bool, at sliderValue: Float) {
        guard let currentPodcast = self.podcast,
              let playingPodcast = model.playingPodcast,
              currentPodcast.matches(podcast: playingPodcast) else {
            return
        }
        if value {
            didStartSeeking(at: sliderValue)
        } else {
            didEndSeeking(at: sliderValue)
        }
    }
    
    func seekBarView(_ view: SeekBarView, didChangeSlider value: Float) {
        guard let currentPodcast = self.podcast,
              let playingPodcast = model.playingPodcast,
              currentPodcast.matches(podcast: playingPodcast) else {
            return
        }
        didChangeSeeking(at: value)
    }
    
    func didChangeSeeking(at sliderValue: Float) {
        seekBar.updateSeekBarLabels(currentDuration * Double(sliderValue), currentDuration)
    }
    
    func didStartSeeking(at sliderValue: Float) {
    }
    
    func didEndSeeking(at sliderValue: Float) {
        seek(to: sliderValue * Float(currentDuration))
    }

    func seek(to: Float) {
        seekBar.slider.isUserInteractionEnabled = false
        model.seek(to: TimeInterval(to)) { [weak self] in
            self?.seekBar.slider.isUserInteractionEnabled = true
        }
    }
}

extension PlayerViewController: AdCompanionViewDelegate {
    func adCompanionViewWillLoad(_ adCompanionView: AdCompanionView) {
        //prepare for a quick animation before companion displays its content
        companionContainerView.alpha = 0
    }
    
    func adCompanionViewDidDisplay(_ adCompanionView: AdCompanionView) {
        //perform the animation to smoothen the appearance of the companion view
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.companionContainerView.alpha = 1
        }
    }
    
    func adCompanionViewDidEndDisplay(_ adCompanionView: AdCompanionView) {
        artworkImageView.isHidden = false
        companionContainerView.isHidden = true
    }
}
