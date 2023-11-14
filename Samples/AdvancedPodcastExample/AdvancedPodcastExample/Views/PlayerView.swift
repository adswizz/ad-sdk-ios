//
//  PlayerView.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 31.08.2023.
//

import UIKit
import AdswizzSDK

class PlayerView: UIView {
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        return stackView
    }()

    let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .horizontal
        return stackView
    }()

    let mediaVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 8.0
        return stackView
    }()

    lazy private(set) var seekBar: SeekBarView = {
        let seekBar = SeekBarView()
        seekBar.translatesAutoresizingMaskIntoConstraints = false
        seekBar.delegate = self
        return seekBar
    }()
    
    let mediaStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()

    let mediaPreviousButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 15)
        button.setImage(UIImage.init(systemName: "backward.fill", withConfiguration: config), for: .normal)
        return button
    }()
    
    let mediaPlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        button.setImage(UIImage.init(systemName: "play.fill", withConfiguration: config), for: .normal)
        return button
    }()

    let mediaNextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 15)
        button.setImage(UIImage.init(systemName: "forward.fill", withConfiguration: config), for: .normal)
        return button
    }()

    let artworkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.init(systemName: "music.quarternote.3"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Podcast name - by AdswizzSDK team"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    var model: AppModel {
        return AppModelInstance
    }
    var state: Playlist.State {
        return model.currentState
    }
    var podcast: PodcastConfig.Podcast? {
        return model.playingPodcast
    }
    var currentDuration: TimeInterval = 0 // the total duration reported once play starts
    
    deinit {
        model.remove(listener: self)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        backgroundColor = .clear
        
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.addArrangedSubview(seekBar)
                
        horizontalStackView.addArrangedSubview(artworkImageView)
        horizontalStackView.addArrangedSubview(mediaVerticalStackView)
        
        mediaVerticalStackView.addArrangedSubview(titleLabel)
        mediaVerticalStackView.addArrangedSubview(mediaStackView)

        mediaStackView.addArrangedSubview(mediaPreviousButton)
        mediaStackView.addArrangedSubview(mediaPlayButton)
        mediaStackView.addArrangedSubview(mediaNextButton)
        NSLayoutConstraint.activate([
            artworkImageView.widthAnchor.constraint(equalToConstant: 54.0),
            seekBar.heightAnchor.constraint(equalToConstant: 44.0),
            
            mediaPreviousButton.heightAnchor.constraint(equalToConstant: 44.0),
            mediaPlayButton.heightAnchor.constraint(equalToConstant: 44.0),
            mediaNextButton.heightAnchor.constraint(equalToConstant: 44.0),
            
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
        
        mediaPreviousButton.addTarget(self, action: #selector(playPrevious), for: .touchUpInside)
        mediaPlayButton.addTarget(self, action: #selector(playCurrent), for: .touchUpInside)
        mediaNextButton.addTarget(self, action: #selector(playNext), for: .touchUpInside)
        
        model.add(listener: self)
    }
    
    @objc func playCurrent() {
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
    
    @objc func playPrevious() {
        model.playPrevious()
    }
    
    @objc func playNext(_ view: PlayerView) {
        model.playNext()
    }
}

extension PlayerView: AppModelListenerDelegate {
    func appModel(_ appModel: AppModelProtocol, stateWillChange state: Playlist.State, for podcast: PodcastConfig.Podcast) {
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        switch state {
        case .starting:
            // loading
            titleLabel.text = "\(podcast.title) - by \(podcast.author)"
            break
        case .started:
            // playing
            mediaPlayButton.setImage(UIImage.init(systemName: "pause.fill", withConfiguration: config), for: .normal)
            break
        case .paused:
            // paused
            mediaPlayButton.setImage(UIImage.init(systemName: "play.fill", withConfiguration: config), for: .normal)
            break
        case .stopping, .stopped:
            // finished
            break
        }
    }
    
    func appModel(_ appModel: AppModelProtocol, playheadChanged playhead: TimeInterval, duration: TimeInterval, for podcast: PodcastConfig.Podcast) {
        currentDuration = duration
        seekBar.updateSeekBarLabels(playhead, currentDuration)
    }
    
    func appModel(_ appModel: AppModelProtocol, didEncounterError error: Error, for podcast: PodcastConfig.Podcast) {
    }
    
    func appModel(_ appModel: AppModelProtocol, didStartPlaying ad: AdData, withCompanion: Bool) {
    }
    
    func appModel(_ appModel: AppModelProtocol, didEndPlaying ad: AdData, withCompanion: Bool) {
    }
}

extension PlayerView: SeekBarViewDelegate {
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

extension SeekBarView {
    func updateSeekBarLabels(_ playhead: TimeInterval, _ duration: TimeInterval) {
        var secondsText = String(format: "%02d", Int(duration) % 60)
        var minutesText = String(format: "%02d", Int(duration) / 60)
        lengthLabel.text = "\(minutesText):\(secondsText)"
        
        secondsText = String(format: "%02d", Int(playhead) % 60)
        minutesText = String(format: "%02d", Int(playhead) / 60)
        startLabel.text = "\(minutesText):\(secondsText)"
        
        slider.setValue(Float(playhead/duration), animated: false)
    }
}
