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
        if #available(tvOS 17.0, *) {
            return PermissionValue(from: AVCaptureDevice.authorizationStatus(for: .video))
        } else {
            return .cantAsk
        }
    }
    
    func request(completion: @escaping RequestCompletion) {
        if #available(tvOS 17.0, *) {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(RequestResult(success: granted ? .granted : .denied))
            }
        } else {
            completion(RequestResult(success: .cantAsk))
        }
    }
}

extension PermissionValue {
    @available(tvOS 17.0, *)
    init(from status: AVAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
        case .authorized: self = .granted
        default: self = .cantAsk
        }
    }
}
