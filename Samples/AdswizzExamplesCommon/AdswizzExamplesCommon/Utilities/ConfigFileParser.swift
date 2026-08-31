//
//  ConfigFileParser.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 16.06.2026.
//

import Foundation

public enum ConfigFileParser {

    public static func buildFromConfigFile(
        scenarioName: String,
        defaultZoneId: String = "12561",
        watchSupport: WatchSupport? = nil
    ) -> AdRequestConfigModelProtocol {
        var config: NSDictionary?
        if let path = Bundle.main.path(forResource: "AdswizzSDKConfig", ofType: "plist") {
            config = NSDictionary(contentsOfFile: path)
        }

        guard let scenario = config?[scenarioName] as? Dictionary<String, Any>,
              let modelName = scenario["modelName"] as? String,
              let zoneId = scenario["zoneId"] as? String,
              let adServer = scenario["adServer"] as? String,
              let companionZones = scenario["companionZones"] as? String,
              let description = scenario["description"] as? String
        else {
            print("[Error!!!] Invalid config for \(scenarioName). Used the default config instead.")
            return AdRequestConfigModel(defaultZoneId, watchSupport)
        }

        return AdRequestConfigModel(modelName, zoneId, adServer, companionZones, description, watchSupport)
    }
}
