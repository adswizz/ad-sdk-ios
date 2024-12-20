//
//  HLSInterstitialModelView.swift
//  AdvancedHLSInterstitialExample
//
//  Created by George Mihoc on 18.12.2024.
//

import AdswizzSDK

class HLSInterstitialModelView: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var playhead: String?
    @Published var duration: String?
    @Published var shouldDisplayAdCompanionView: Bool = false
    @Published var isAdBreak: Bool = false
    @Published var isPausedAd: Bool = false
    @Published var logs: [BasicHLSLog] = []
    
    lazy var model: Model = {
        let model = Model()
        model.mediaDelegate = self
        model.logDelegate = self
        model.adBreakDelegate = self
        return model
    }()
    
    func start() {
        isPlaying = true
        model.play()
    }
    
    func stop() {
        isPlaying = false
        isAdBreak = false
        model.stop()
    }
    
    func pauseAd() {
        model.pauseAd()
        isPausedAd = true
    }
    
    func resumeAd() {
        model.resumeAd()
        isPausedAd = false
    }
    
    func skipAd() {
        model.skipAd()
    }
}

private extension HLSInterstitialModelView {
    func updatePlayhead(_ playhead: TimeInterval, _ duration: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let isLive = duration == Double.greatestFiniteMagnitude
            if isLive {
                self.duration = "LIVE"
            } else {
                let secondsText = String(format: "%02d", Int(duration) % 60)
                let minutesText = String(format: "%02d", Int(duration) / 60)
                self.duration = "\(minutesText):\(secondsText)"
            }
            
            let secondsText = String(format: "%02d", Int(playhead) % 60)
            let minutesText = String(format: "%02d", Int(playhead) / 60)
            self.playhead = "\(minutesText):\(secondsText)"
        }
    }
}

extension HLSInterstitialModelView: ModelMediaDelegate {
    func model(_ model: Model, didChangeState state: MediaPlayerStatus) {
        if state == .initialized {
            return
        }
        if state == .failed {
            return logs.append(BasicHLSLog(title: model.playerLastError?.localizedDescription ?? "An unknown player error occured"))
        }
        logs.append(BasicHLSLog(title: "HLS Stream Event", message: state.stringValue))
    }
    
    func model(_ model: Model, didChangePlayhead playhead: TimeInterval) {
        updatePlayhead(playhead, Double.greatestFiniteMagnitude)
    }
}

extension HLSInterstitialModelView: ModelLogDelegate {
    func model(_ model: Model, didLog event: BasicHLSLog) {
        logs.append(event)
    }
}

extension HLSInterstitialModelView: ModelAdBreakDelegate {
    func model(_ model: Model, didChangePlayhead playhead: TimeInterval, outOf duration: TimeInterval) {
        updatePlayhead(playhead, duration)
    }
    
    func modelDidStartAdBreak(_ model: Model) {
        isAdBreak = true
    }
    
    func modelDidEndAdBreak(_ model: Model) {
        isAdBreak = false
    }
}

extension HLSInterstitialModelView: AdCompanionViewDelegate {
    func adCompanionViewWillLoad(_ adCompanionView: AdCompanionView) {
        shouldDisplayAdCompanionView = true
    }
    
    func adCompanionViewDidDisplay(_ adCompanionView: AdCompanionView) {
        shouldDisplayAdCompanionView = true
    }
    
    func adCompanionView(_ adCompanionView: AdCompanionView, didFailToDisplay error: any Error) {
        shouldDisplayAdCompanionView = false
    }
    
    func adCompanionViewDidEndDisplay(_ adCompanionView: AdCompanionView) {
        shouldDisplayAdCompanionView = false
    }
}
