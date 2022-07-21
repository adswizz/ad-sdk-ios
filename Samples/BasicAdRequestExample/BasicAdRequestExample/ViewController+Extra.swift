//
//  ViewController+Extra.swift
//  BasicAdRequestExample
//
//  Created by Adrian Manolache on 06/16/2022.
//  Copyright © 2022 Inc, AdsWizz. All rights reserved.
//

import Foundation

extension ViewController {
    func buildFromConfigFile(scenarioName: String) -> ViewControllerModelProtocol {
        
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
            return build()
        }
        
        return ViewControllerModel(modelName, zoneId, adServer, companionZones, description)
    }
}
