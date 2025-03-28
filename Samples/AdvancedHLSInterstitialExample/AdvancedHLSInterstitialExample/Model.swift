//
//  Model.swift
//  AdvancedHLSInterstitialExample
//
//  Created by George Mihoc on 18.12.2024.
//

import AVFoundation
import AdswizzSDK

protocol MediaModel: AnyObject {
    func play()
    func pauseAd()
    func resumeAd()
    func skipAd()
    func stop()
}

protocol ModelAdBreakDelegate: AnyObject {
    func modelDidStartAdBreak(_ model: Model)
    func modelDidEndAdBreak(_ model: Model)
    func model(_ model: Model, didChangePlayhead playhead: TimeInterval, outOf duration: TimeInterval)
}

protocol ModelMediaDelegate: AnyObject {
    func model(_ model: Model, didChangeState state: MediaPlayerStatus)
    func model(_ model: Model, didChangePlayhead playhead: TimeInterval)
}

protocol ModelLogDelegate: AnyObject {
    func model(_ model: Model, didLog event: BasicHLSLog)
}

enum Status {
    case buffering
    case readyToPlay
    case playing
    case paused
    case stopped
}

struct BasicHLSLog: Loggable {
    let title: String
    let subtitle: String?
    let message: String?
    
    init(title: String, subtitle: String? = nil, message: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.message = message
    }
    
    var hasMessage: Bool { message != nil }
}

class Model: NSObject {
    // The HLS url stream (primary playlist)
    let url = URL(string: "https://streaming.sdk.eks.devel.adswizz.com/addictalternative/playlist.m3u8")
    
    // Handles the HLS interstitials.
    private(set) var controller: InterstitialController?
    
    //Delegates.
    weak var mediaDelegate: ModelMediaDelegate?
    weak var adBreakDelegate: ModelAdBreakDelegate?
    weak var logDelegate: ModelLogDelegate?
    private(set) var state: Status = .stopped
    
    // Primary player.
    private let player: MediaPlayer

    // Internal state if the model is observing or not the primary player.
    private var observing: Bool

    // Internal flag to indicate if primary player is reporting any loading e.g buffering.
    var isLoading: Bool { player.playerStatus == .buffering }
    
    // Last error reported by the primary player.
    var playerLastError: Error? { player.lastError }
    
    // Current playhead reported by the primary player.
    var playerCurrentPlayhead: TimeInterval { player.currentPlayhead }
    
    // This describes the current adBreak e.g number of ads to be played, current playhead etc.
    var currentAdBreakDescription: String?
    var currentAdIndex = 0
    
    override init() {
        observing = true
        player = MediaPlayer()
        super.init()
        (player as NSObject).addObserver(self, forKeyPath: "currentPlayhead", options: [.new], context: nil)
        (player as NSObject).addObserver(self, forKeyPath: "playerStatus", options: [.initial, .new], context: nil)
    }
    
    deinit {
        detach()
    }
}

extension Model: MediaModel {
    func play() {
        guard let url else { return }
        logDelegate?.model(self, didLog: BasicHLSLog(title: "HLS Stream will start playing"))

        // Stop current streaming if running
        stop()
        
        // Prepare the primary player for running the HLS stream
        state = .buffering
        player.prepare(with: url)
        
        // Play
        player.play()
        
        // Create the HLS controller
        controller?.stop()
        controller?.adBreakDelegate = nil
        controller = InterstitialController(with: player)
        controller?.adBreakDelegate = self
    }
    
    func stop() {
        // Stop the primary player.
        player.stop()
        player.replaceCurrentItem(with: nil)
        state = .stopped
        
        // Stop the interstitial controller.
        controller?.stop()
        controller?.adBreakDelegate = nil
    }

    func pauseAd() {
        controller?.pauseAd()
    }
    
    func resumeAd() {
        controller?.playAd()
    }
    
    func skipAd() {
        controller?.skipAd()
    }
    
    func skipAllAds() {
        controller?.skipAllAds()
    }
}

extension Model {
    private func detach() {
        if !observing {
            return
        }
        observing = false
        (player as NSObject).removeObserver(self, forKeyPath: "currentPlayhead")
        (player as NSObject).removeObserver(self, forKeyPath: "playerStatus")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "currentPlayhead":
            if let value = change?[.newKey] as? Double {
                playHeadProgressChanged(value)
            }
        case "playerStatus":
            if let value = change?[.newKey] as? Int, let status = MediaPlayerStatus(rawValue: value) {
                playerStatusChanged(status)
            }
        default:
            break
        }
    }
    
    private func playHeadProgressChanged(_ time: TimeInterval) {
        if player.playerStatus != .playing || (player.playerStatus == .bufferingFinished && state == .playing) {
            return
        }
        mediaDelegate?.model(self, didChangePlayhead: time)
    }

    private func playerStatusChanged(_ newPlayerStatus: MediaPlayerStatus) {
        switch newPlayerStatus {
        case .buffering:
            state = .buffering
        case .readyToPlay, .bufferingFinished:
            state = .readyToPlay
        case .playing:
            let previouslyPaused = self.state == .paused
            state = .playing
            if !previouslyPaused {
                controller?.start()
            }
        case .paused:
            state = .paused
        case .finished, .failed, .unknown, .initialized:
            fallthrough
        @unknown default:
            state = .stopped
        }
        mediaDelegate?.model(self, didChangeState: newPlayerStatus)
    }
}

extension Model: InterstitialAdBreakDelegate {
    func controller(_ controller: InterstitialController, didRequestAds result: AdRequestResult) {
        if case .failure = result {
            logDelegate?.model(self, didLog: BasicHLSLog(title: "Failed to retrieve AdManager"))
            return
        }
        do {
            let adManager = try result.get()
            logDelegate?.model(self, didLog: BasicHLSLog(title: "Successfully retrieved AdManager adCount = \(adManager.ads.count), totalAdsDuration = \(adManager.ads.compactMap { $0.duration }.reduce(0, +)) s"))
            currentAdBreakDescription = "Ads • <ad> of \(adManager.ads.count) • <playhead>"
        } catch {
            logDelegate?.model(self, didLog: BasicHLSLog(title: "Failed to retrieve AdManager"))
        }
    }
    
    func controller(_ controller: InterstitialController, didStartAdBreak interstitialAdBreak: InterstitialAdBreak?) {
        guard let interstitialAdBreak else { return }
        adBreakDelegate?.modelDidStartAdBreak(self)
        logDelegate?.model(self, didLog: BasicHLSLog(title: "Start playing HLS interstitial \(interstitialAdBreak.interstitial.identifier)"))
    }
    
    func controller(_ controller: InterstitialController, didEndAdBreak interstitialAdBreak: InterstitialAdBreak?) {
        guard let interstitialAdBreak else { return }
        adBreakDelegate?.modelDidEndAdBreak(self)
        logDelegate?.model(self, didLog: BasicHLSLog(title: "Finish playing HLS interstitial \(interstitialAdBreak.interstitial.identifier)"))
    }
    
    func controller(_ controller: InterstitialController, didReceiveAdBreakEvent adBreakEvent: AdEvent, error: Error?, for interstitialAdBreak: InterstitialAdBreak?) {
        defer {
            currentAdIndex = interstitialAdBreak?.adManager.ads.firstIndex(where: {adBreakEvent.ad === $0}) ?? 0
        }
        
        if let error {
            print("Received error: \(error.localizedDescription) while playing ad with id = \(adBreakEvent.ad?.id ?? "unknown")")
            logDelegate?.model(self, didLog: BasicHLSLog(title: "Error", message: "AdManager encountered an error!"))
            return
        }
        
        print("Received \(adBreakEvent.stringEvent)")
        let eventType = adBreakEvent.event
        let leftLine = adBreakEvent.ad?.id ?? nil != nil ? "\(adBreakEvent.ad?.id ?? "unknown")" : nil
        logDelegate?.model(self, didLog: BasicHLSLog(title: "Ad Event", subtitle: leftLine, message: eventType.toString()))
    }
    
    func controller(_ controller: InterstitialController, didChangePlayhead playhead: TimeInterval, outOf duration: TimeInterval) {
        if duration != Double.greatestFiniteMagnitude && duration > 0 {
            adBreakDelegate?.model(self, didChangePlayhead: playhead, outOf: duration)
        }
    }
}
