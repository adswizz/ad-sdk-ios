//
//  SpeechRequester.swift
//  AdswizzSDKPrivacyDataSpeech
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import Speech

/// Requester implementation for the `SFSpeechRecognizer` system permission.
///
/// - note: The `AdswizzSDKPrivacyDataCore` module links the `SpeechRequester` automatically at runtime if the `AdswizzSDKPrivacyDataSpeech` module is installed as library.
///
/// - see: Apple's document on user privacy for details of available authorisations
/// https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy
///
@objc class SpeechRequester: NSObject, RequesterProtocol {
    var authorizationStatus: PermissionValue {
        return PermissionValue(from: SFSpeechRecognizer.authorizationStatus())
    }
    
    func request(completion: @escaping RequestCompletion) {
        SFSpeechRecognizer.requestAuthorization { status in
            completion(RequestResult(success: PermissionValue(from: status)))
        }
    }
}

extension PermissionValue {
    init(from status: SFSpeechRecognizerAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
        case .authorized: self = .granted
        default: self = .cantAsk
        }
    }
}
