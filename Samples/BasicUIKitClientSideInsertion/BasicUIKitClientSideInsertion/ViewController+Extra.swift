//
//  ViewController+Extra.swift
//  BasicUIKitClientSideInsertion
//
//  Created by George Mihoc on 22.04.2026.
//  Copyright © 2026 Inc, AdsWizz. All rights reserved.
//

import Foundation
import AdswizzExamplesCommon

extension ViewController {
    func buildFromConfigFile(scenarioName: String) -> AdRequestConfigModelProtocol {
        ConfigFileParser.buildFromConfigFile(scenarioName: scenarioName)
    }
}
