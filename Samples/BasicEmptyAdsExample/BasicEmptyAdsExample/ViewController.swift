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
    
    lazy var logView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .boldSystemFont(ofSize: 17)
        view.textColor = .label
        view.textAlignment = .left
        view.isEditable = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Empty ads" + " - AdsWizz SDK v" + Bundle(for: AdswizzAdRequest.self).version
        
        view.addSubview(logView)
        NSLayoutConstraint.activate([
            logView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logView.topAnchor.constraint(equalTo: view.topAnchor),
            logView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
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
