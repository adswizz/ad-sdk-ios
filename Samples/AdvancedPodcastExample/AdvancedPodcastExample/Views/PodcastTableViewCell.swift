//
//  PodcastTableViewCell.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 29.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var playingIndicator: PlayingIndicatorView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with podcast: PodcastConfig.Podcast, state: Playlist.State) {
        playingIndicator.barCount = 4
        playingIndicator.barSpacing = 2
        playingIndicator.tintColor = .systemBlue
        title.text = podcast.title
        subtitle.text = podcast.author
        
        let isPlaying = (state != .stopping && state != .stopped)
        playingIndicator.isHidden = !isPlaying
        icon.isHidden = isPlaying
        playingIndicator.setState(state.toIndicatorState(), animated: true)
    }
}

extension Playlist.State {
    func toIndicatorState() -> PlayingIndicatorView.State {
        switch self {
        case .starting, .started: return .play
        case .paused: return .pause
        case .stopping, .stopped: return .stop
        }
    }
}
