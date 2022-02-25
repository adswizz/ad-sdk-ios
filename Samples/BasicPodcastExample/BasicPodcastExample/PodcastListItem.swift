//
//  PodcastListItem.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 14.02.2022.
//

import Foundation
import UIKit
import AdswizzSDK

protocol PodcastListItemDelegate: AnyObject {
    func startedDownload(id: Int)
    
    func stoppedDownload(id: Int)
    
    func finishedDownload(id: Int)
    
    func updatedDownloadProgress(id: Int, percent: Float)
}

class PodcastListItem {
    let title: String
    let url: URL
    let podcastManager: AdswizzAdPodcastManager?
    let id: Int
    private var isDownloaded = false
    weak var delegate: AdPodcastManagerDelegate?
    weak var podcastItemDelegate: PodcastListItemDelegate?
    
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
        
        do {
            podcastManager = try AdswizzAdPodcastManager.Builder()
                    .with(adServer: "demo.deliveryengine.adswizz.com")
                    .with(httpProtocol: .http)
                    .with(companionZones: "") // optional, if no companion zone id is found in the vast file this id will be used instead
                    .build()
        } catch {
            print("Could not build podcastManager: \(error.localizedDescription)")
            podcastManager = nil
        }
    }

    func downloadPressed() {
        if isDownloaded {
            stopAndRemoveDownload()
        } else {
            startDownload()
        }
        isDownloaded = !isDownloaded
    }
    
    private func startDownload() {
        podcastManager?.downloadDelegate = self
        do {
            try podcastManager?.startDownloadPodcast(with: url, to: url.getPathForPodcast())
        } catch {
            print("Error \(error) occured while starting download at \(url)")
        }
        podcastItemDelegate?.startedDownload(id: id)
    }
    
    private func stopAndRemoveDownload() {
        do {
            try podcastManager?.stopDownloadPodcast(at: url.getPathForPodcast())
            try podcastManager?.removePodcast(at: url.getPathForPodcast())
        } catch {
            print("Error \(error) when removing download for \(url)")
        }
        podcastItemDelegate?.stoppedDownload(id: id)
    }
    
    func play() {
        podcastManager?.delegate = delegate
        
        let shouldUseCustomPlayer = false
        if shouldUseCustomPlayer {
            /*
            player = MyCustomPlayer() // Should implement MyCustomPlayer conforming to MediaPlayerState
            let settings = AdPodcastManagerSettings()
            settings.player = player
            podcastManager.adPodcastManagerSettings = settings
            */
        } else  {
            let settings = podcastManager?.adPodcastManagerSettings ?? AdPodcastManagerSettings()
            settings.player = nil
            podcastManager?.adPodcastManagerSettings = settings
        }
        
        AdswizzSDK.shared.disableRAD = true
        
        do {
            try podcastManager?.play(with: url)
        } catch {
            print("Could not play podcastManager: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        podcastManager?.stop()
    }
    
    func pause() {
        podcastManager?.pause()
    }
    
    func resume() {
        podcastManager?.resume()
    }
    
    func seek(to: Float) {
        try? podcastManager?.seek(to: TimeInterval(to))
    }
}

extension PodcastListItem: AdPodcastManagerDownloadDelegate {
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didDownload bytesDownloaded: Int64, outOf bytesExpected: Int64, for asset: DownloadableAsset) {
        print("adPodcastManager didDownload \(bytesDownloaded) of \(bytesExpected) for \(asset.url)")
        podcastItemDelegate?.updatedDownloadProgress(id: id, percent: Float(bytesDownloaded) / Float(bytesExpected))
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didFinishDownload asset: DownloadableAsset) {
        print("adPodcastManager didFinishDownload for \(asset.url)")
        podcastItemDelegate?.finishedDownload(id: id)
    }
    
    func adPodcastManager(_ adPodcastManager: AdPodcastManager, didReceive error: Error, for asset: DownloadableAsset) {
        print("adPodcastManager didReceive for \(asset.url)")
    }
}
