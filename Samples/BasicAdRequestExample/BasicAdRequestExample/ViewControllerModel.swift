//
//  ViewControllerModel.swift
//  BasicAdRequestExample
//
//  Created by Teodor Cristea on 05/03/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation

protocol ViewControllerModelProtocol {
    var zoneId: String { get }
    var adServer: String { get }
    var companionZones: String { get }
    var watchSupport: WatchSupport? { get }
}

protocol ViewControllerModelBuilder {
    func build() -> ViewControllerModelProtocol
}

struct ViewControllerModel: ViewControllerModelProtocol {
    let zoneId: String
    let adServer: String = "demo.deliveryengine.adswizz.com"
    let companionZones: String = "12562"
    let watchSupport: WatchSupport?
    
    init(_ zoneId: String, _ watchSupport: WatchSupport? = nil) {
        self.zoneId = zoneId
        self.watchSupport = watchSupport
    }
}
