//
//  MainViewModel.swift
//  BasicPodcastExample
//
//  Created by George Mihoc on 19.01.2026.
//

import AdswizzSDK
import AdswizzExamplesCommon
import AVFoundation
import SwiftUI

final class MainViewModel: PodcastAdViewModel {

    @Published var selectedPodcastId: Int = 0
    @Published var podcasts: [PodcastItemState] = []

    private var podcastItems: [PodcastListItem] = []

    override init() {
        super.init()
        setup()
    }

    var currentPodcastItem: PodcastListItem? {
        podcastItems.first { $0.id == selectedPodcastId }
    }
    
    func togglePlayStop() {
        isPlaying ? stopPodcast() : playPodcast()
    }
    
    func togglePauseResume() {
        isPaused ? resumePodcast() : pausePodcast()
    }

    func seek(to time: Float) {
        try? podcastManager?.seek(to: TimeInterval(time)) {
            // Seek operation finished
        }
    }

    func downloadPressed(for id: Int) {
        if let index = podcastItems.firstIndex(where: { $0.id == id }) {
            podcastItems[index].downloadPressed()
        }
    }

    private func playPodcast() {
        guard let item = currentPodcastItem else { return }

        if podcastManager == nil {
            do { try configurePodcastManager() } catch { return }
            podcastItems.forEach { $0.podcastManager = podcastManager }
        }

        let settings = AdPodcastManagerSettings()
        if useExternalPlayer {
            settings.player = item.externalPlayer
        }
        podcastManager?.adPodcastManagerSettings = settings

        AdswizzSDK.shared.disableRAD = true

        play(url: item.url)
    }
    
    private func stopPodcast() {
        if useExternalPlayer {
            currentPodcastItem?.stopExternalPlayer()
        }
        stop()
    }
    
    private func pausePodcast() {
        if useExternalPlayer {
            currentPodcastItem?.pauseExternalPlayer()
        } else {
            pause()
        }
    }
    
    private func resumePodcast() {
        if useExternalPlayer {
            currentPodcastItem?.playExternalPlayer()
        } else {
            resume()
        }
    }

    override func onWillStartPlaying(url: URL) {
        if useExternalPlayer {
            currentPodcastItem?.prepareExternalPlayer(url: url)
            currentPodcastItem?.playExternalPlayer()
        }
    }

    override func onPodcastPlayerShouldSeek(to time: TimeInterval, completion: @escaping @Sendable () -> Void) {
        currentPodcastItem?.externalPlayerSeek(to: time, completion: completion)
    }
}

private extension MainViewModel {
    func setup() {
        podcastItems = [
            PodcastListItem(title: "Podcast 1", url: URL(string: "https://streaming.sdk.eks.devel.adswizz.com/podcast/podcast_RAD_QueenBohemian.mp3")!),
            PodcastListItem(title: "Podcast 2", url: URL(string: "https://streaming.sdk.eks.devel.adswizz.com/podcast/podcast_RAD_muchosEvents.mp3")!),
            PodcastListItem(title: "Podcast 3", url: URL(string: "https://streaming.sdk.eks.devel.adswizz.com/podcast/podcast_RAD_sampleFile.mp3")!)
        ]

        podcasts = podcastItems.map {
            PodcastItemState(id: $0.id, title: $0.title, filename: $0.url.lastPathComponent)
        }

        podcastItems.forEach { $0.podcastItemDelegate = self }

        if let first = podcasts.first {
            selectedPodcastId = first.id
        }
    }
}

extension MainViewModel: PodcastListItemDelegate {
    func startedDownload(id: Int) {
        if let index = podcasts.firstIndex(where: { $0.id == id }) {
            podcasts[index].isDownloading = true
            podcasts[index].downloadProgress = 0
        }
    }
    
    func stoppedDownload(id: Int) {
        if let index = podcasts.firstIndex(where: { $0.id == id }) {
            podcasts[index].isDownloading = false
            podcasts[index].isDownloaded = false
            podcasts[index].downloadProgress = 0
        }
    }
    
    func finishedDownload(id: Int) {
        if let index = podcasts.firstIndex(where: { $0.id == id }) {
            podcasts[index].isDownloading = false
            podcasts[index].isDownloaded = true
            podcasts[index].downloadProgress = 1.0
        }
    }
    
    func updatedDownloadProgress(id: Int, percent: Float) {
        if let index = podcasts.firstIndex(where: { $0.id == id }) {
            podcasts[index].downloadProgress = percent
        }
    }
}
