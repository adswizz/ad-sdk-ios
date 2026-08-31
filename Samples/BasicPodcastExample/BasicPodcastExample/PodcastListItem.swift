//
//  PodcastListItem.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 14.02.2022.
//

import Foundation
import AVFoundation
import UIKit
import AdswizzSDK
import AdswizzExamplesCommon

@MainActor protocol PodcastListItemDelegate: AnyObject {
    func startedDownload(id: Int)
    func stoppedDownload(id: Int)
    func finishedDownload(id: Int)
    func updatedDownloadProgress(id: Int, percent: Float)
}

@MainActor class PodcastListItem {
    let title: String
    let url: URL
    let id: Int

    weak var podcastItemDelegate: PodcastListItemDelegate?

    weak var podcastManager: AdswizzAdPodcastManager?
    var externalPlayer = ExternalMediaPlayer()

    private var isDownloaded = false

    private static var currentID = 0
    private static func getNextId() -> Int {
        let id = currentID
        currentID += 1
        return id
    }
    
    init(title: String, url: URL) {
        self.id = PodcastListItem.getNextId()
        self.title = title
        self.url = url
    }

    func prepareExternalPlayer(url: URL) {
        externalPlayer.prepare(with: url)
    }

    func playExternalPlayer() {
        externalPlayer.play()
    }
    
    func pauseExternalPlayer() {
        externalPlayer.pause()
    }
    
    func stopExternalPlayer() {
        externalPlayer.stop()
    }
    
    func externalPlayerSeek(to: TimeInterval, completion: @escaping @Sendable () -> Void) {
        let seekTime = CMTime(value: Int64(to), timescale: 1)
        externalPlayer.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { finished in
            if finished {
                //let the SDK know that your player finished the seek operation
                completion()
            }
        }
    }

    func downloadPressed() {
        Task {
            if isDownloaded {
                await stopAndRemoveDownload()
            } else {
                await startDownload()
            }
            isDownloaded = !isDownloaded
        }
    }

    private func startDownload() async {
        podcastManager?.downloadDelegate = self
        do {
            try await podcastManager?.startDownloadPodcast(with: url, to: url.getPathForPodcast())
        } catch {
            print("Error \(error) occured while starting download at \(url)")
        }
        podcastItemDelegate?.startedDownload(id: id)
    }

    private func stopAndRemoveDownload() async {
        do {
            try await podcastManager?.stopDownloadPodcast(at: url.getPathForPodcast())
            try podcastManager?.removePodcast(at: url.getPathForPodcast())
        } catch {
            print("Error \(error) when removing download for \(url)")
        }
        podcastItemDelegate?.stoppedDownload(id: id)
    }
}

extension PodcastListItem: @MainActor AdPodcastManagerDownloadDelegate {
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didDownload bytesDownloaded: Int64, outOf bytesExpected: Int64, for asset: DownloadableAsset) {
        print("adPodcastManager didDownload \(bytesDownloaded) of \(bytesExpected) for \(asset.url)")
        let percent = Float(bytesDownloaded) / Float(bytesExpected)
        podcastItemDelegate?.updatedDownloadProgress(id: id, percent: percent)
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didFinishDownload asset: DownloadableAsset) {
        print("adPodcastManager didFinishDownload for \(asset.url)")
        podcastItemDelegate?.finishedDownload(id: id)
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didReceive error: Error, for asset: DownloadableAsset) {
        print("adPodcastManager didReceive for \(asset.url)")
    }
}
