//
//  MotionActivityManagerImpl.swift
//  AdswizzSDKPrivacyDataMotion
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import CoreMotion

@objc class MotionActivityManagerImpl: NSObject, MotionActivityManager {
    let manager = CMMotionActivityManager()
    
    func startActivity(to queue: OperationQueue, withHandler handler: @escaping (MotionActivity?) -> ()) {
        
        if !CMMotionActivityManager.isActivityAvailable() {
            return
        }
        
        manager.startActivityUpdates(to: queue) { activity in
            handler(activity)
        }
    }
    func stopActivity() {
        manager.stopActivityUpdates()
    }

}

extension CMMotionActivity: MotionActivity {
    public var activityConfidence: MotionActivityConfidence {
        MotionActivityConfidence(from: confidence) ?? .low
    }
}

extension MotionActivityConfidence {
    init?(from confidence: CMMotionActivityConfidence) {
        switch confidence {
        case .low: self = .low
        case .high: self = .high
        case .medium: self = .medium
        default:
            return nil
        }
    }
}
