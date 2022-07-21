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
}
