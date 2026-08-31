//
//  MainViewModel.swift
//  BasicVideoAdExample
//
//  Created by George Mihoc on 18.01.2026.
//

import AdswizzSDK
import AdswizzExamplesCommon
import SwiftUI
import UIKit

enum SkipState {
    case initial
    case inactive(value: String)
    case active
}

extension AdVideoState {
    var stringValue: String {
        switch self {
        case .collapsed: return "collapsed"
        case .expanded: return "expanded"
        case .fullscreen: return "fullscreen"
        case .minimized: return "minimized"
        case .normal:
            fallthrough
        @unknown default:
            return "normal"
        }
    }
}

final class MainViewModel: ClientSideAdViewModel {

    @Published var adCountText: String = "0/0 ads"
    @Published var totalAdsDurationText: String = "totalAdsDuration: 0.0 seconds"
    @Published var isPlayingAds: Bool = false
    @Published var isLoading: Bool = false
    @Published var isFullscreen: Bool = false
    @Published var skipState: SkipState = .initial
    @Published var showSkipButton: Bool = false
    @Published var showVideoView: Bool = false
    
    let adVideoView: AdVideoView = {
        let view = AdVideoView(frame: .zero)
        view.backgroundColor = .black
        return view
    }()
    
    let skipOffset: NSNumber = NSNumber(floatLiteral: 5)
    private var currentAdIndex = 0

    override var zoneIds: [String] { ["19984", "17862"] }

    override init() {
        super.init()
        externalPlayer = ExternalMediaPlayer()
    }
    
    func didTapActionButton() {
        if isPlayingAds {
            stop()
            withAnimation {
                isPlayingAds = false
                showVideoView = false
                showSkipButton = false
                isLoading = false
            }
        } else {
            requestAds()
            isPlayingAds = true
        }
    }
    
    func didTapSkipAd() {
        skipAd()
    }
    
    func didDoubleTapVideo() {
        withAnimation {
            isFullscreen.toggle()
        }
    }

    override func buildAdRequest(zones: [AdswizzAdZone]) throws -> AdRequest {
        try AdswizzAdRequest.Builder()
            .with(httpProtocol: .http)
            .with(server: adServer)
            .with(zones: zones)
            .build()
    }

    override func configureAdManager(_ adManager: AdManager?) {
        adManager?.delegate = self
        adManager?.interactiveDelegate = self

        let settings = AdManagerSettings()
        adVideoView.delegate = self
        settings.videoView = adVideoView

        if useExternalPlayer, let player = externalPlayer {
            settings.player = player
            attachExternalVideoView(player.playerView)
        }

        adManager?.adManagerSettings = settings
    }

    override func onAdEvent(_ event: AdEvent) {
        switch event.event {
        case .preparingForPlay:
            isLoading = true
            if adType(for: event.ad) == .video {
                withAnimation { showVideoView = true }
            }
            currentAdIndex += 1
            externalPlayerSwitchEnabled = false

        case .didStartPlaying:
            isLoading = false
            if adType(for: event.ad) == .video {
                showSkipButton = true
                showVideoView = true
            } else {
                showSkipButton = false
                showVideoView = false
            }

        case .didFinishPlaying:
            if adType(for: event.ad) == .video {
                showSkipButton = false
            }

        default:
            break
        }
        updateTexts()
    }

    override func onAllAdsCompleted() {
        super.onAllAdsCompleted()
        withAnimation {
            isPlayingAds = false
            showVideoView = false
            showSkipButton = false
            isFullscreen = false
        }
        currentAdIndex = 0
    }

    override func onPlayheadChanged(ad: AdData, playHead: TimeInterval, duration: TimeInterval) {
        var offset = ad.skipOffset
        if offset == nil {
            offset = skipOffset // mocked
        }
        if let offset, playHead < offset.doubleValue {
            let value = Int(offset.doubleValue - playHead)
            skipState = .inactive(value: "\(value)")
        } else {
            skipState = .active
        }
    }
}

private extension MainViewModel {
    func adType(for ad: AdData?) -> AdType {
        ad?.adType ?? .audio
    }
    
    func attachExternalVideoView(_ videoView: UIView) {
        guard videoView.superview == nil else { return }
        videoView.translatesAutoresizingMaskIntoConstraints = false
        adVideoView.insertSubview(videoView, at: 0)
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: adVideoView.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: adVideoView.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: adVideoView.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: adVideoView.bottomAnchor)
        ])
    }

    func updateTexts() {
        adCountText = "\(currentAdIndex)/\(adManager?.adCount ?? 0) ads"
        totalAdsDurationText = "totalAdsDuration: \(adManager?.totalAdsDuration ?? 0) seconds"
    }
}

extension MainViewModel: @MainActor AdVideoViewDelegate {
    func adVideoView(_ adVideoView: AdVideoView, shouldOverrideVideoClickThrough url: URL) -> Bool {
        return false
    }

    func adVideoViewWillLeaveApplication(_ adVideoView: AdVideoView) {
        // Called only if you return false in shouldOverrideVideoClickThrough
    }
}
