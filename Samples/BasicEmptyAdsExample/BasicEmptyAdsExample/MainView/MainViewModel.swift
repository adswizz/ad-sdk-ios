//
//  MainViewModel.swift
//  BasicEmptyAdsExample
//
//  Created by George Mihoc on 20.01.2026.
//

import AdswizzSDK
import AdswizzExamplesCommon
import SwiftUI

final class MainViewModel: ClientSideAdViewModel, Loggable {

    @Published var logs: String = ""

    var title: String { "Empty ads - " + sdkVersionString }

    override var adServer: String { "demo.deliveryengine.adswizz.com" }
    override var zoneIds: [String] { ["14946"] }

    override init() {
        super.init()
        addLog("Requesting ads")
        requestAds()
    }

    override func buildAdRequest(zones: [AdswizzAdZone]) throws -> AdRequest {
        try AdswizzAdRequest.Builder()
            .with(httpProtocol: .http)
            .with(server: adServer)
            .with(zones: zones)
            .build()
    }

    override func configureAdManager(_ adManager: AdManager?) {
        super.configureAdManager(adManager)
        addLog("Starting the adManager with adCount = \(adManager?.ads.count ?? 0)")
    }

    override func onAdEvent(_ event: AdEvent) {
        addLog("Received message \(event.stringEvent)")

        switch event.event {
        case .readyForPlay:
            if let ad = event.ad, ad.isEmpty {
                print("Encountered an empty ad!")
                addLog("Detected empty ad!")
            }
        default:
            break
        }
    }
}
