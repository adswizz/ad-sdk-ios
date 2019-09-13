//
//  ViewController.swift
//  Swift-sample
//
//  Created by Teodor Cristea on 13/09/2019.
//  Copyright © 2019 Inc, AdsWizz. All rights reserved.
//

import UIKit
import AudioAdSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = AdswizzAdRequest.Builder().with(companionAdsEnabled: true).build()
        let connection = AdRequestConnection.init(for: request)
    }


}

