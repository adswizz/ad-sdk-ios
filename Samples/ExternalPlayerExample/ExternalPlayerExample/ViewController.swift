//
//  ViewController.swift
//  ExternalPlayer
//
//  Created by Bogdan Cosescu on 20/04/2020.
//  Copyright © 2020 Adswizz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let model = Model()
    @IBOutlet weak var logView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        model.requestAds()
    }
}

extension ViewController: ModelDelegate {
    func model(_ model: Model, log line: String) {
        logView.text = logView.text + line + "\n"
    }
}

