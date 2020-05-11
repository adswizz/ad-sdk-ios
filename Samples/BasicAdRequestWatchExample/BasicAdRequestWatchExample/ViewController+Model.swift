//
//  ViewController+Model.swift
//  BasicAdRequestWatchExample
//
//  Created by Teodor Cristea on 05/03/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation
import UIKit

class WatchSupportImpl: WatchSupport {
    var hasSupport: Bool {
        get {
            return true
        }
    }
    
    func sendMessage(_ state: State) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.sendMessage(state)
    }
}

extension ViewController: ViewControllerModelBuilder {
    func build() -> ViewControllerModelProtocol {
        return ViewControllerModel("13381", WatchSupportImpl())
    }
}
