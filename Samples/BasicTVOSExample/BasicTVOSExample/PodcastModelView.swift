//
//  PodcastModelView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 02.12.2024.
//

import Foundation
import AdswizzSDK
import AdswizzExamplesCommon

final class PodcastModelView: PodcastAdViewModel {
    private let podcastURL: String

    init(podcastURL: String) {
        self.podcastURL = podcastURL
        super.init()
    }
    
    func start() {
        guard let url = URL(string: podcastURL) else { return }
        play(url: url)
    }

    func skip() {
        skipCurrentAd()
    }
}
