//
//  ViewController+Model.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 05/03/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation

extension ViewController: ViewControllerModelBuilder {
    func build() -> ViewControllerModelProtocol {
        return ViewControllerModel("12561")
    }
    
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
