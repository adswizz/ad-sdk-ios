//
//  BaseAdViewModel.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK
import Combine

@MainActor open class BaseAdViewModel: ObservableObject {

    @Published public var status: String = ""
    @Published public var isPlaying: Bool = false
    @Published public var isPaused: Bool = false
    @Published public var hasCompanionView: Bool = false
    @Published public var showSkipAd: Bool = false
    @Published public var useExternalPlayer: Bool = false
    @Published public var externalPlayerSwitchEnabled: Bool = true
    @Published public var adswizzSDKVersion: String = ""

    public var adManager: AdManager?

    public init() {
        adswizzSDKVersion = sdkVersionString
    }

    open func onAllAdsCompleted() {
        hasCompanionView = false
        showSkipAd = false
    }

    open func onCompanionStateChanged(hasCompanion: Bool) {
        hasCompanionView = hasCompanion
    }

    public func skipAd() {
        adManager?.skipAd()
    }

    public var sdkVersionString: String {
        "AdsWizz SDK v" + Bundle(for: AdswizzAdRequest.self).version
    }
}
