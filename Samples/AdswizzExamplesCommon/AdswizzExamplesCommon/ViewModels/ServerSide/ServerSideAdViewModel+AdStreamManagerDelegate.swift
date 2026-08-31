//
//  ServerSideAdViewModel+AdStreamManagerDelegate.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK
import AVFoundation

extension ServerSideAdViewModel: AdStreamManagerDelegate {
    public func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL) {
        print("Received ad stream manager event: willStartPlaying -> \(url)")
        if useExternalPlayer {
            externalPlayer?.prepare(with: url)
            externalPlayer?.play()
        }
    }

    public func adStreamManager(_ adstreamManager: AdStreamManager, adBreakStarted manager: AdManager) {
        print("Received ad stream manager event: adBreakStarted")
        onAdBreakStarted(manager: manager)
    }

    public func adStreamManager(_ adstreamManager: AdStreamManager, adBreakEnded manager: AdManager) {
        print("Received ad stream manager event: adBreakEnded")
        onAdBreakEnded()
    }

    public func adStreamManager(_ adstreamManager: AdStreamManager, stateChanged state: MediaPlayerStatus) {
        print("Received ad stream manager event: stateChanged -> \(state.stringValue)")
    }

    public func adStreamManager(_ adstreamManager: AdStreamManager, metadataChanged metadata: [AVMetadataItem]) {
        print("Received ad stream manager event: metadataChanged")
    }

    public func adStreamManager(_ adstreamManager: AdStreamManager, didReceive dvrMetadata: AdStreamDVRMetadata?) {
        self.dvrMetadata = dvrMetadata
        print("Received ad stream manager DVR metadata:\n\(dvrMetadata?.dvrDescription ?? "nil")")
    }

    public func adStreamManagerWillReconnect(_ adstreamManager: AdStreamManager) {
        print("Received ad stream manager event: willReconnect")
    }

    public func adStreamManagerPlayerShouldPause(_ adstreamManager: AdStreamManager) {
        print("Received ad stream manager event: playerShouldPause")
    }

    public func adStreamManagerPlayerShouldResume(_ adstreamManager: AdStreamManager) {
        print("Received ad stream manager event: playerShouldResume")
    }
}
