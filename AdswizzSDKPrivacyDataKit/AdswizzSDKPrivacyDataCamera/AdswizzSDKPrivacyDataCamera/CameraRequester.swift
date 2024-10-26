//
//  CameraRequester.swift
//  AdswizzSDKPrivacyDataCamera
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import AVFoundation

/// Requester implementation for the camera system permission.
///
/// - note: The `AdswizzSDKPrivacyDataCore` module links the `CameraRequester` automatically at runtime if the `AdswizzSDKPrivacyDataCamera` module is installed as library.
///
/// - see: Apple's document on user privacy for details of available authorisations
/// https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy
///
@objc class CameraRequester: NSObject, RequesterProtocol {
    var authorizationStatus: PermissionValue {
        return PermissionValue(from: AVCaptureDevice.authorizationStatus(for: .video))
    }
    
    func request(completion: @escaping RequestCompletion) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            completion(RequestResult(success: granted ? .granted : .denied))
        }
    }
}

extension PermissionValue {
    init(from status: AVAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
        case .authorized: self = .granted
        default: self = .cantAsk
        }
    }
}
