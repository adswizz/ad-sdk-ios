//
//  ViewController.swift
//  BasicAnalyticsExample
//
//  Created by Teodor Cristea on 21.07.2023.
//

import UIKit

class ViewController: UIViewController {
    let model = Model()
    @IBOutlet var logView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = model.title
        
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
        // update text
        logView.text = logView.text + line + "\n"
        
        //auto-scroll to bottom
        if logView.text.count > 0 {
            let location = logView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            logView.scrollRangeToVisible(bottom)

            // an iOS bug, see https://stackoverflow.com/a/20989956/971070
            logView.isScrollEnabled = false
            logView.isScrollEnabled = true
        }
    }
}
