//
//  MainController.swift
//  BasicAdRequestWatch Extension
//
//  Created by Teodor Cristea on 04/03/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import WatchKit
import Foundation

class MainController: WKInterfaceController {
    @IBOutlet weak var status: WKInterfaceLabel!
    var state: Status = .none
    
    enum Status: Int, CaseIterable {
        case none
        case playingAds
        case playingContent
        
        var name: String {
            switch self {
            case .none: return "Idle"
            case .playingAds: return "Playing ads..."
            case .playingContent: return "Playing content..."
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setState(state)
    }
        
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Get notified of messages from iOS app
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).appMessage(_:)),
            name: .messageReceived, object: nil
        )
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension MainController {
    func setState(_ state: Status) {
        status.setText(state.name)
    }
    
    @objc func appMessage(_ notification: Notification) {
        guard
            let raw = notification.userInfo?["WatchMessage"] as? String,
            let state = WatchPlaybackState(rawValue: raw)
        else {
            return
        }
        
        switch state {
        case .playingAds: setState(.playingAds)
        case .playingContent: setState(.playingContent)
        }
    }
}
