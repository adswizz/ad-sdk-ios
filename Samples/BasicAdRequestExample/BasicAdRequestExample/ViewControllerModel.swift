//
//  ViewControllerModel.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 05/03/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation

protocol ViewControllerModelProtocol {
    var modelName: String { get }
    var zoneId: String { get }
    var adServer: String { get }
    var companionZones: String { get }
    var description: String { get }
    var watchSupport: WatchSupport? { get }
}

protocol ViewControllerModelBuilder {
    func build() -> ViewControllerModelProtocol
}

struct ViewControllerModel: ViewControllerModelProtocol {
    var modelName: String = "Model name"
    let zoneId: String
    var adServer: String = "demo.deliveryengine.adswizz.com"
    var companionZones: String = "12562"
    var description: String = "Model description"
    let watchSupport: WatchSupport?
    
    init(_ zoneId: String, _ watchSupport: WatchSupport? = nil) {
        self.zoneId = zoneId
        self.watchSupport = watchSupport
    }
    
    init(_ modelName: String, _ zoneId: String, _ adServer: String, _ companionZones: String, _ description: String, _ watchSupport: WatchSupport? = nil) {
        self.modelName = modelName
        self.zoneId = zoneId
        self.adServer = adServer
        self.companionZones = companionZones
        self.description = description
        self.watchSupport = watchSupport
    }
}
