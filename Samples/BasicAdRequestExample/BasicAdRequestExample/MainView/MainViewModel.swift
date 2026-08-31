//
//  MainViewModel.swift
//  BasicAdRequestExample
//
//  Created by George Mihoc on 14.01.2026.
//  Copyright © 2026 Inc, AdsWizz. All rights reserved.
//

import AdswizzSDK
import AdswizzExamplesCommon
import AVFoundation
import PassKit
import SwiftUI

final class MainViewModel: ClientSideAdViewModel {

    @Published var title: String = ""
    @Published var isPresentingPassSheet: Bool = false
    @Published var pendingPass: PKPass?

    var model: AdRequestConfigModelProtocol?
    private var audioPlayer = AVAudioPlayer()
    private var isContentPlaying = false
    private var timer: Timer?

    override var adServer: String { model?.adServer ?? super.adServer }
    override var zoneIds: [String] { [model?.zoneId].compactMap { $0 } }
    override var companionZones: String { model?.companionZones ?? super.companionZones }

    override init() {
        super.init()
        externalPlayer = ExternalMediaPlayer()
        setup()
    }
    
    func didTapRequestAds() {
        requestAds()
    }
    
    func didTapSkipAds() {
        skipAd()
    }

    override func configureAdManager(_ adManager: AdManager?) {
        super.configureAdManager(adManager)
        adManager?.datasource = self

        // Send watch message
        model?.watchSupport?.sendMessage(.playingAds)
    }

    override func playContent() {
        if !isContentPlaying {
            audioPlayer.play()
            isContentPlaying = true
            status = "Playing content..."
            
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(updateTime),
                                         userInfo: nil,
                                         repeats: true)
            
            // Send watch message if paired
            model?.watchSupport?.sendMessage(.playingContent)
        }
    }
    
    override func pauseContent() {
        guard isContentPlaying else { return }
        audioPlayer.pause()
        isContentPlaying = false
        status = "Content paused..."
    }

    override func onAdEvent(_ event: AdEvent) {
        switch event.event {
        case .didStartPlaying:
            if let firstFile = event.ad?.asset.mediaUrl, let firstFileURL = URL(string: firstFile) {
                updateNowPlaying(with: NowPlayableStaticMetadata(assetURL: firstFileURL,
                                                                 isLiveStream: false,
                                                                 title: "Adswizz Ad",
                                                                 artist: "Basic Ad Request",
                                                                 artwork: nil))
            }
        default:
            break
        }
    }

    override func onCouponReceived(_ pkpassData: Data) {
        do {
            let receivedPass = try PKPass(data: pkpassData)
            pendingPass = receivedPass
            isPresentingPassSheet = true
        } catch {
            print("Failed to create PKPass: \(error)")
        }
    }

    override func onInteractiveAdEvent(_ event: InteractiveAdEvent) {
        switch event.event {
        case .willBeSkipped:
            break
        case .skipped:
            break
        case .extended:
            break
        default:
            break
        }
    }
}

private extension MainViewModel {
    func setup() {
        title = "Request AdsWizz ads"

        // Prepare model
        /// Check AdswizzSDKConfig.plist for all the values.
        /// Possible values: "NormalAds", "InteractiveAds", "AskPermissionAds", "InteractiveVoiceAds"
        model = ConfigFileParser.buildFromConfigFile(scenarioName: "NormalAds")
        
        // Prepare content playback
        let path = Bundle.main.path(forResource: "content_example", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        // Start content
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            playContent()
        } catch {
            // can't load file
        }
    }

    @objc func updateTime() {
        let currentTime = Int(audioPlayer.currentTime)
        let minutes = currentTime/60
        let seconds = currentTime - minutes * 60
        
        playedTime = String(format: "%02d:%02d", minutes, seconds)
    }
}
