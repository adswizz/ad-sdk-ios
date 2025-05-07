//
//  ContentViewController.swift
//  BasicDVRRequestExample
//
//  Created by Teodor Cristea on 23.04.2025.
//

import UIKit

protocol ContentViewControllerDelegate: AnyObject {
    func content(_ contentViewController: ContentViewController, didTapPlayFromTimestamp button: UIButton)
    func content(_ contentViewController: ContentViewController, didTapPlayFromPredefinedTimestamp button: UIButton)
}

class ContentViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet var startLabel: UITextField!
    @IBOutlet var endLabel: UITextField!
    @IBOutlet var bufferLabel: UILabel!
    @IBOutlet var playFromTimestampButton: UIButton!
    @IBOutlet var playFromTimestampTextField: UITextField!
    @IBOutlet var predefinedTimestamps: UIStackView!
    
    weak var delegate: ContentViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        playFromTimestampTextField.delegate = self
    }
    
    @IBAction func playFromTimestamp(button: UIButton) {
        delegate?.content(self, didTapPlayFromTimestamp: button)
    }
    
    @IBAction func playPredefinedTimestamp(button: UIButton) {
        delegate?.content(self, didTapPlayFromPredefinedTimestamp: button)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
