//
//  ClientSideModelView.swift
//  BasicTVOSExample
//
//  Created by George Mihoc on 18.11.2024.
//

import Foundation
import AdswizzSDK
import AdswizzExamplesCommon

final class ClientSideModelView: ClientSideAdViewModel {
    var videoView: AdVideoView? = nil

    @Published var adType: AdType?
    @Published var companionGrid: AdCompanionViewGridType = .single
    @Published var refreshCompanionGrid = false
    @Published var hiddenDictionary: [Int: Bool] = [:]

    private let configZoneIds: [String]
    private let configCompanionZone: String

    override var zoneIds: [String] { configZoneIds }
    override var companionZones: String { configCompanionZone }

    init(zoneIds: [String], companionZone: String) {
        self.configZoneIds = zoneIds
        self.configCompanionZone = companionZone
        super.init()
        initHiddenDictionary()
    }

    override func buildAdRequest(zones: [AdswizzAdZone]) throws -> AdRequest {
        try AdswizzAdRequest.Builder()
            .with(httpProtocol: .http)
            .with(server: adServer)
            .with(zones: zones)
            .with(companionZoneIds: companionZones.components(separatedBy: CharacterSet(charactersIn: ",")).compactMap { Int($0) })
            .build()
    }

    override func configureAdManager(_ adManager: AdManager?) {
        super.configureAdManager(adManager)

        if let adManager {
            videoView = AdVideoView()
            let settings = AdManagerSettings()
            settings.videoView = videoView
            adManager.adManagerSettings = settings
        }
    }

    override func onAdEvent(_ event: AdEvent) {
        switch event.event {
        case .readyForPlay:
            adType = event.ad?.adType
            hasCompanionView = event.ad?.hasCompanion ?? false
        case .allAdsCompleted:
            videoView = nil
            adType = nil
        default:
            break
        }
    }

    func skip() {
        skipAd()
    }
    
    func increaseAdCompanionGrid() {
        refreshCompanionGrid = true
        companionGrid = companionGrid.increasedGrid
        refreshCompanionGrid = false
    }
    
    func decreaseAdCompanionGrid() {
        refreshCompanionGrid = true
        companionGrid = companionGrid.decreasedGrid
        refreshCompanionGrid = false
    }
    
    func shouldHideCompanionView(for index: Int) -> Bool {
        hiddenDictionary[index] ?? false
    }
    
    func toggleHideCompanionView(for index: Int) {
        hiddenDictionary[index]?.toggle()
    }

    private func initHiddenDictionary() {
        let maxQuantity = AdCompanionViewGridType.allCases.map { $0.quantity }.max() ?? 0
        hiddenDictionary = Dictionary(uniqueKeysWithValues: (0..<maxQuantity).map { ($0, false) })
    }
}
