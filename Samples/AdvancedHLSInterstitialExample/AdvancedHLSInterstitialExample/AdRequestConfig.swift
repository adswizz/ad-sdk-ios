//
//  AdRequestConfig.swift
//  AdvancedHLSInterstitialExample
//
//  Created by George Mihoc on 18.12.2024.
//

import AdswizzSDK

// Configuration object for an `AdswizzAdRequest`
class AdRequestConfig {
    let adServer: String
    let zoneIds: [String]
    let companionZones: String?
    let customParams: String?
    let interstitialConfig: InterstitialConfig
    
    struct InterstitialConfig {
        let identifier: String
        let requestTimeOffset: TimeInterval
        let eventTimeOffset: TimeInterval
    }
    
    // Builder class for `AdRequestConfig`
    class Builder {
        private var adServer: String?
        private var zoneIds: [String]?
        private var companionZones: String?
        private var customParams: String?
        private var interstitialConfig: InterstitialConfig = .defaultConfig

        func with(interstitialConfig: InterstitialConfig) -> Builder {
            self.interstitialConfig = interstitialConfig
            return self
        }
        
        func with(adServer: String) -> Builder {
            self.adServer = adServer
            return self
        }

        func with(zoneIds: [String]) -> Builder {
            self.zoneIds = zoneIds
            return self
        }
                
        func with(companionZones: String) -> Builder {
            self.companionZones = companionZones
            return self
        }
                
        func with(customParams: String) -> Builder {
            self.customParams = customParams
            return self
        }
        
        // Builds an `AdRequestConfig` object
        func build() -> AdRequestConfig? {
            guard let zoneIds, let adServer else { return nil }
            return AdRequestConfig(adServer: adServer, zoneIds: zoneIds, companionZones: companionZones, customParams: customParams, interstitialConfig: interstitialConfig)
        }
    }
    
    private init(adServer: String, zoneIds: [String], companionZones: String?, customParams: String?, interstitialConfig: InterstitialConfig) {
        self.adServer = adServer
        self.zoneIds = zoneIds
        self.companionZones = companionZones
        self.customParams = customParams
        self.interstitialConfig = interstitialConfig
    }
}

extension AdRequestConfig {
    @MainActor func adswizzAdRequest() throws -> AdswizzAdRequest {
        do {
            let zones: [AdswizzAdZone] = zoneIds.compactMap { $0.toAdswizzAdZone() }
            let request = try AdswizzAdRequest.Builder()
                .with(httpProtocol: .http)
                .with(zones: zones)
                .with(server: adServer)
                .with(companionZoneIds: companionZones?.components(separatedBy: CharacterSet(charactersIn: ",")).compactMap { Int($0) } ?? [])
                .with(additionalCustomParameters: customParams)
                .build()
            return request
        } catch {
            throw error
        }
    }
}

fileprivate extension String {
    @MainActor func toAdswizzAdZone() -> AdswizzAdZone? {
        return try? AdswizzAdZone.Builder().with(zoneId: self).build()
    }
}

private extension AdRequestConfig.InterstitialConfig {
    static let defaultConfig: AdRequestConfig.InterstitialConfig = AdRequestConfig.InterstitialConfig(identifier: "AdswizzInterstitialEvent",
                                                                                                      requestTimeOffset: 5,
                                                                                                      eventTimeOffset: 5)
}
