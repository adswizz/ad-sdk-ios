//
//  AppDelegate+Logger.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 29.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation
import AdswizzSDKCore
import XCGLogger

let Log: XCGLogger = AppDelegate.log

extension AppDelegate {
    func configureLogger() {
        // Create a logger object with no destinations
        AppDelegate.log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
        AppDelegate.log.configure()
        AdLogger.shared.level = .verbose
        AdLogger.shared.destination = AppDelegate.log
        
        // Add basic app info, version info etc, to the start of the logs
        AppDelegate.log.logAppDetails()
    }
}
