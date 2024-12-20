//
//  InterstitialController.swift
//  AdvancedHLSInterstitialExample
//
//  Created by George Mihoc on 18.12.2024.
//

import AVFoundation
import AdswizzSDK

// This class encapsulates and pairs an adpod driven by an`AdManager` (holding one or more `AdData` objects) with an `AVPlayerInterstitialEvent`.
class InterstitialAdBreak {
    let adManager: AdManager
    let interstitial: AVPlayerInterstitialEvent
    
    init(adManager: AdManager, interstitial: AVPlayerInterstitialEvent) {
        self.adManager = adManager
        self.interstitial = interstitial
    }
}

// The `InterstitialController` ad break delegate.
protocol InterstitialAdBreakDelegate: AnyObject {
    func controller(_ controller: InterstitialController, didChangePlayhead playhead: TimeInterval, outOf duration: TimeInterval)
    func controller(_ controller: InterstitialController, didStartAdBreak interstitialAdBreak: InterstitialAdBreak?)
    func controller(_ controller: InterstitialController, didEndAdBreak interstitialAdBreak: InterstitialAdBreak?)
    func controller(_ controller: InterstitialController, didReceiveAdBreakEvent adBreakEvent: AdEvent, error: Error?, for interstitialAdBreak: InterstitialAdBreak?)
    func controller(_ controller: InterstitialController, didRequestAds result: AdRequestResult)
}

// The `InterstitialController` class drives the logic behind working with an `AdManager` from `AdswizzSDK`
// and the native HLS interstitial support provided by the `AVPlayer` (primary player) in conjunction with `AVQueuePlayer` (interstitial player) from `AVFoundation`.
class InterstitialController: NSObject {
    // AdswizzSDK.
    private var scheduler: AdRequestScheduler = AdRequestSchedulerImpl()
    var configs: [AdRequestConfig] = {
        var configs: [AdRequestConfig] = []
        let adServer = "demo.deliveryengine.adswizz.com"
        
        // First adbreak (interstitial) config:
        // it tries to fetch 2 ads from Adswizz AdServer
        // it uses the following insertion strategy:
        // - the AdswizzAdRequest (which fetches an AdManager handling the 2 ads with a total of a maximum 25 seconds duration) is triggered 5 seconds into the stream
        // - the interstitial event associated with the AdManager is scheduled to be triggered at another 5 seconds into the stream
        if let config = AdRequestConfig.Builder()
            .with(adServer: adServer)
            .with(zoneIds: ["17862", "13381"])
            .with(interstitialConfig: AdRequestConfig.InterstitialConfig(identifier: "AdswizzInterstitialEvent1", requestTimeOffset: 5, eventTimeOffset: 5))
            .build() { //will be triggered after 5 seconds from its schedule time
            configs.append(config)
        }
        
        // Second adbreak (interstitial) config:
        // it tries to fetch 1 ad from Adswizz AdServer
        // it uses the following insertion strategy:
        // - the AdswizzAdRequest (which fetches an AdManager handling the 1 ad with a total of a maximum 31 seconds duration) is triggered 35 seconds into the stream
        // - the interstitial event associated with the AdManager is scheduled to be triggered at 40 seconds into the stream
        if let config = AdRequestConfig.Builder()
            .with(adServer: adServer)
            .with(zoneIds: ["12561"])
            .with(companionZones: "12562")
            .with(interstitialConfig: AdRequestConfig.InterstitialConfig(identifier: "AdswizzInterstitialEvent2", requestTimeOffset: 35, eventTimeOffset: 40))
            .build() { //will be triggered after 35 seconds from its schedule time
            configs.append(config)
        }
        
        return configs
    }()
    
    // Interstitial ad breaks.
    private var adBreaks: [InterstitialAdBreak] = []
    private var currentInterstitial: InterstitialAdBreak?
    
    //Delegates.
    weak var adBreakDelegate: InterstitialAdBreakDelegate?
    
    // Primary player implementation.
    private let primaryPlayer: MediaPlayer
    
    // The observer for interstitial events
    private lazy var observer: AVPlayerInterstitialEventMonitor = {
        let observer = AVPlayerInterstitialEventMonitor(primaryPlayer: primaryPlayer)
        return observer
    }()
    private lazy var controller: AVPlayerInterstitialEventController = {
        let controller = AVPlayerInterstitialEventController(primaryPlayer: primaryPlayer)
        return controller
    }()
    
    // The current list of scheduled events.
    private(set) var currentEvents: [AVPlayerInterstitialEvent] = []
    
    // The current list of received events. Will be emptied when there are scheduled events.
    private(set) var receivedEvents: [AVPlayerInterstitialEvent] = []
    
    init(with primaryPlayer: MediaPlayer) {
        self.primaryPlayer = primaryPlayer
        super.init()
        attach()
    }
    
    deinit {
        detach()
        scheduler.unscheduleAll()
    }
    
    func start() {
        scheduler.unscheduleAll()
        scheduler.scheduleFinished = { [weak self] result, config in
            guard let self else { return }
            switch result {
            case let .success(adManager):
                adManager.delegate = self
                let adPodTemplates = adManager.avPlayerItems
                
                if adPodTemplates.isEmpty {
                    print("[Interstitial] Failed to schedule empty AdManager to mark the insertion opportunity!")
                }
                
                let isFirstAdManager = adBreaks.isEmpty
                let event = AVPlayerInterstitialEvent(primaryItem: primaryPlayer.currentItem!,
                                                      identifier: config.interstitialConfig.identifier,
                                                      time: CMTime(seconds: primaryPlayer.currentPlayhead + config.interstitialConfig.eventTimeOffset, preferredTimescale: 1),
                                                      templateItems: adPodTemplates,
                                                      restrictions: [],
                                                      resumptionOffset: .zero)
                adBreaks.append(InterstitialAdBreak(adManager: adManager, interstitial: event))
                
                if isFirstAdManager {
                    adBreaks.first?.adManager.start(monitor: observer)
                }
                
                //schedule the new event on the controller
                let allEvents: [AVPlayerInterstitialEvent] = controller.events.map {
                    guard let copy = $0.copy() as? AVPlayerInterstitialEvent else {
                        return nil
                    }
                    return copy
                }.compactMap { $0 } + [event]
                controller.events = allEvents
                print("[Interstitial] All current scheduled events = \(controller.events.map { $0.identifier })")
            case .failure(_):
                break
            }
        }
        
        configs.forEach { [weak self] in
            self?.scheduler.schedule(adRequest: $0)
        }
    }
    
    func stop() {
        scheduler.unscheduleAll()
        adBreaks.forEach { $0.adManager.reset() }
        adBreaks = []
        currentInterstitial = nil
        
        currentEvents = []
        receivedEvents = []
        controller.events = []
    }
    
    func playAd() {
        currentInterstitial?.adManager.play()
    }
    
    func pauseAd() {
        currentInterstitial?.adManager.pause()
    }
    
    func skipAd() {
        currentInterstitial?.adManager.skipAd()
    }
    
    func skipAllAds() {
        currentInterstitial?.adManager.reset()
        controller.cancelCurrentEvent(withResumptionOffset: .zero)
    }
}

private extension InterstitialController {
    func attach() {
        NotificationCenter.default.addObserver(
            forName: AVPlayerInterstitialEventMonitor.eventsDidChangeNotification,
            object: observer,
            queue: OperationQueue.main) { [weak self] notification in
                if self?.adBreaks.isEmpty ?? false {
                    self?.controller.events = []
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: AVPlayerInterstitialEventMonitor.currentEventDidChangeNotification,
            object: observer,
            queue: OperationQueue.main) { [weak self] notification in
                guard let self else { return }
                print("[Interstitial] Playing interstitial = \(String(describing: observer.currentEvent?.identifier)) at playhead = \(String(describing: observer.currentEvent?.time.seconds))")
                
                if let current = currentInterstitial, observer.currentEvent == nil {
                    adBreakDelegate?.controller(self, didEndAdBreak: current)
                    
                    //remove current interstitial from ad breaks collection.
                    adBreaks = adBreaks.filter { $0.interstitial.identifier != current.interstitial.identifier }
                    
                    //remove the current interstitial from the controller
                    let remainingEvents: [AVPlayerInterstitialEvent] = controller.events.map {
                        guard let copy = $0.copy() as? AVPlayerInterstitialEvent else { return nil }
                        return copy
                    }.compactMap { $0 }.filter { $0.identifier != current.interstitial.identifier }
                    controller.events = remainingEvents
                    
                    currentInterstitial = nil
                    
                    //kick-off the AdManager for the next upcoming interstitial event
                    adBreaks.first?.adManager.start(monitor: observer)
                    
                    print("[Interstitial] Remaining scheduled interstitial events = \(controller.events.map { $0.identifier })")
                    controller.events.forEach {
                        print("[Interstitial] Event = \($0.identifier) scheduled at playhead = \($0.time.seconds) with player items = \($0.templateItems.map { ($0.asset as? AVURLAsset)?.url })")
                    }
                }
                
                guard let event = observer.currentEvent,
                      let currentInterstitial = adBreaks.filter({ $0.interstitial.identifier == event.identifier }).first,
                      currentInterstitial.adManager.ads.count != 0 else {
                    return
                }
                self.currentInterstitial = currentInterstitial
                adBreakDelegate?.controller(self, didStartAdBreak: currentInterstitial)
            }
    }
    
    func detach() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension InterstitialController: AdManagerDelegate {
    func adManager(_ adManager: AdManager, didReceiveAdEvent event: AdEvent) {
        adBreakDelegate?.controller(self, didReceiveAdBreakEvent: event, error: nil, for: currentInterstitial)
        switch event.event {
        case .readyForPlay:
            if let ad = event.ad, ad.isEmpty {
                adManager.play()
            }
        default:
            break
        }
    }
    
    func adManager(_ adManager: AdManager, didReceiveAd ad: AdData?, error: Error) {
        print("AdManager didReceiveError = \(error)")
        adBreakDelegate?.controller(self, didReceiveAdBreakEvent: AdBreakEventMock(ad: ad), error: error, for: currentInterstitial)
    }
    
    func adManager(_ adManager: AdManager, ad: AdData, didChangedPlayHead playHead: TimeInterval, adDuration duration: TimeInterval) {
        print("Playhead changed for HLS interstitial player to \(playHead) out of \(duration) seconds")
        adBreakDelegate?.controller(self, didChangePlayhead: playHead, outOf: duration)
    }
}

class AdBreakEventMock: NSObject, AdEvent {
    let ad: AdData?
    let event: AdEventType = .unknown
    let extraAdData: [String : Any]? = nil
    let stringEvent: String = ""
    
    init(ad: AdData?) {
        self.ad = ad
    }
}

//for convenience, let's make the `AVPlayerInterstitialEventMonitor` observer conform to AdswizzSDK's `AdInterstitialEventMonitor`.
//then you can set the observer to the `adInterstitialEventMonitor` property of AdManagerSettings when configuring an AdManager.
extension AVPlayerInterstitialEventMonitor: @retroactive AdInterstitialEventMonitor {}

extension AdManager {
    func start(monitor: AdInterstitialEventMonitor?) {
        if adManagerSettings.adInterstitialEventMonitor == nil {
            adManagerSettings.adInterstitialEventMonitor = monitor
        }
        self.prepare()
    }
    
    var allMediaFilesURLs: [URL] {
        return ads.compactMap { adData in
            guard let mediaURL = adData.asset.mediaUrl, let url = URL(string: mediaURL) else {
                return nil
            }
            return url
        }
    }
    
    var avPlayerItems: [AVPlayerItem] {
        return allMediaFilesURLs.map { return AVPlayerItem(url: $0) }
    }
}
