//
//  PhotoRequester.swift
//  AdswizzSDKPrivacyDataPhotos
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import Photos

/// Requester implementation for the Photos system permission.
///
/// - note: The `AdswizzSDKPrivacyDataCore` module links the `PhotoRequester` automatically at runtime if the `AdswizzSDKPrivacyDataPhotos` module is installed as library.
///
/// - see: Apple's document on user privacy for details of available authorisations
/// https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy
///
@objc class PhotoRequester: NSObject, RequesterProtocol {
    var authorizationStatus: PermissionValue {
        return PermissionValue(from: PHPhotoLibrary.authorizationStatus())
    }
    
    func request(completion: @escaping RequestCompletion) {
        PHPhotoLibrary.requestAuthorization { status in
            completion(RequestResult(success: PermissionValue(from: status)))
        }
    }
}

extension PermissionValue {
    init(from status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
        case .authorized: self = .granted
        default: self = .cantAsk
        }
    }
}
