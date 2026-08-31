//
//  MainViewModel.swift
//  BasicAnalyticsExample
//
//  Created by George Mihoc on 20.01.2026.
//

import AdswizzSDK
import AdswizzSDKCore
import AdswizzSDKPinpointAnalytics
import AdswizzExamplesCommon

final class MainViewModel: ClientSideAdViewModel, Loggable {

    @Published var logs: String = ""

    var title: String { "Analytics - " + sdkVersionString }

    // Pinpoint connector
    private var pinpointConnector: AdswizzPinpointConnector?

    // Custom connector
    private lazy var customConnector: AppAnalyticsConnector = {
        let connector = AppAnalyticsConnector()
        connector.delegate = self
        return connector
    }()

    override var adServer: String { "demo.deliveryengine.adswizz.com" }
    override var zoneIds: [String] { ["17862"] }

    override init() {
        super.init()
        setupConnectors()
        addLog("Requesting ads")
        requestAds()
    }

    isolated deinit {
        //example of how to remove the connectors if needed
        //however, in practice your app should keep the connector(s) attached as long as the AdswizzSDK remains initialized
        if let pinpointConnector = self.pinpointConnector {
            AdswizzSDK.shared.remove(connector: pinpointConnector)
        }
        AdswizzSDK.shared.remove(connector: self.customConnector)
    }

    /// Clears the log and requests ads again so the test can be repeated without relaunching the app.
    func runAgain() {
        stop()
        logs = ""
        addLog("Requesting ads")
        requestAds()
    }

    func stopTest() {
        stop()
        addLog("Stopped")
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
        // Analytics example doesn't need interactiveDelegate or external player
        addLog("Starting the adManager with adCount = \(adManager?.ads.count ?? 0)")
    }

    override func onAdEvent(_ event: AdEvent) {
        addLog("Received message \(event.stringEvent)")

        switch event.event {
        case .readyForPlay:
            // At any point you can verify if the current ad is empty (non-playable).
            if let ad = event.ad, ad.isEmpty {
                print("Encountered an empty ad!")
                addLog("Detected empty ad!")
            }
        default:
            break
        }
    }

    private func setupConnectors() {
        // Pinpoint connector
        let config = AdswizzPinpointConfiguration(
            region: .AFSouth1,                              // a valid `AWSRegionType`
            projectId: "yourPinpointProjectId",             // a valid AWS Pinpoint projectId
            identityPoolId: "yourPinpointIdentityPoolId"    // a valid AWS Pinpoint identityPoolId key
        )
        do {
            //create an instance of `AdswizzPinpointConnector`
            pinpointConnector = try AdswizzPinpointConnector(with: config)
            //add it to the `AdswizzSDK`
            AdswizzSDK.shared.add(connector: pinpointConnector!)
            print("Successfully created pinpoint connector and added it to AdswizzSDK")
        } catch {
            print("Failed to create pinpoint connector with error = \(error)")
        }

        //add custom connector as well
        customConnector.shouldLog = true
        AdswizzSDK.shared.add(connector: customConnector)
    }
}

extension MainViewModel: AppAnalyticsConnectorDelegate {
    func appAnalyticsConnector(_ connector: AppAnalyticsConnector, didLog event: AnalyticsEvent, with description: String) {
        addLog(description)
    }
}
