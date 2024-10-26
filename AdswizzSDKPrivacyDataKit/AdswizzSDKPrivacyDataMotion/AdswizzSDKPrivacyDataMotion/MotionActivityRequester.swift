//
//  MotionActivityRequester.swift
//  AdswizzSDKPrivacyDataMotion
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import CoreMotion

/// Requester implementation for the motion activity system permission.
///
/// - note: The `AdswizzSDKPrivacyDataCore` module links the `MotionActivityRequester` automatically at runtime if the `AdswizzSDKPrivacyDataMotion` module is installed as library.
///
/// - see: Apple's document on user privacy for details of available authorisations
/// https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy
///
@objc class MotionActivityRequester: NSObject, RequesterProtocol {
    var authorizationStatus: PermissionValue {
        return PermissionValue(from: CMMotionActivityManager.authorizationStatus())
    }
    
    func request(completion: @escaping RequestCompletion) {
        completion(RequestResult(success: .cantAsk))
    }
}

extension PermissionValue {
    init(from status: CMAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
        case .authorized: self = .granted
        default: self = .cantAsk
        }

    }
}
