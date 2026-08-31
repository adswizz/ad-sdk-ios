//
//  MainViewModel.swift
//  ExternalPlayerExample
//
//  Created by George Mihoc on 20.01.2026.
//

import AdswizzSDK
import AdswizzExamplesCommon
import SwiftUI

final class MainViewModel: ClientSideAdViewModel, Loggable {

    @Published var logs: String = ""

    private let mockPlayer = MockExternalMediaPlayer()

    var title: String { "External Player" }

    override var zoneIds: [String] { ["17862"] }

    override init() {
        super.init()
        addLog("Requesting ads")
        requestAds()
    }

    override func configureAdManager(_ adManager: AdManager?) {
        adManager?.delegate = self
        adManager?.interactiveDelegate = self

        let settings = AdManagerSettings()
        settings.player = mockPlayer
        adManager?.adManagerSettings = settings

        addLog("Starting the adManager")
    }

    override func onAdEvent(_ event: AdEvent) {
        addLog("Received message \(event.stringEvent)")

        switch event.event {
        case .preparingForPlay:
            guard let adMedia = event.ad?.asset.mediaUrl else {
                adManager?.skipAd()
                return
            }
            mockPlayer.play(adMedia, duration: 6.0)

        default:
            break
        }
    }
}
