//
//  ViewController+Extra.swift
//  BasicAdRequestWatchExample
//
//  Created by Adrian Manolache on 06/16/2022.
//  Copyright © 2022 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzExamplesCommon

extension ViewController {
    func buildFromConfigFile(scenarioName: String) -> AdRequestConfigModelProtocol {
        ConfigFileParser.buildFromConfigFile(scenarioName: scenarioName)
    }
}
