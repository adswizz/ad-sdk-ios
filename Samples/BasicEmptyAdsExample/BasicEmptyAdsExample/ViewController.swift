//
//  ViewController.swift
//  BasicEmptyAdsExample
//
//  Created by Teodor Cristea on 20/01/2021.
//

import UIKit
import AdswizzSDK

class ViewController: UIViewController {
    let model = Model()
    @IBOutlet var logView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Empty ads" + " - AdsWizz SDK v" + Bundle(for: AdswizzAdRequest.self).version
        
        logView.font = .boldSystemFont(ofSize: 17)
        logView.textColor = .label

        // Request ads
        model.delegate = self
        do {
            try model.requestAds()
        } catch  {
            print(error)
            return
        }
    }
}

extension ViewController: ModelDelegate {
    func model(_ model: Model, log line: String) {
        logView.text = logView.text + line + "\n"
    }
}
