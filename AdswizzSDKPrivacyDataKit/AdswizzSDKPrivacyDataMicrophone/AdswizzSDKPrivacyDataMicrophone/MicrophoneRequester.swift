//
//  MicrophoneRequester.swift
//  AdswizzSDKPrivacyDataMicrophone
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import AVFoundation

/// Requester implementation for the microphone / recording system permission.
///
/// - note: The `AdswizzSDKPrivacyDataCore` module links the `MicrophoneRequester` automatically at runtime if the `AdswizzSDKPrivacyDataMicrophone` module is installed as library.
///
/// - see: Apple's document on user privacy for details of available authorisations
/// https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy
///
@objc class MicrophoneRequester: NSObject, RequesterProtocol {
    var authorizationStatus: PermissionValue {
        if #available(iOS 17.0, tvOS 17.0, *) {
            return PermissionValue(from: AVAudioApplication.shared.recordPermission)
        } else {
            // Fallback on earlier versions on iOS, for earlier tvOS versions return .cantAsk
#if !os(tvOS)
            return PermissionValue(from: AVAudioSession.sharedInstance().recordPermission)
#else
            return .cantAsk
#endif
        }
    }
    
    func request(completion: @escaping RequestCompletion) {
        if #available(iOS 17.0, tvOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                completion(RequestResult(success: granted ? .granted : .denied))
            }
        } else {
            // Fallback on earlier versions on iOS, for earlier tvOS versions return .cantAsk
#if !os(tvOS)
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                completion(RequestResult(success: granted ? .granted : .denied))
            }
#else
            completion(RequestResult(success: .cantAsk))
#endif
        }
    }
}

extension PermissionValue {
    init(from status: AVAudioSession.RecordPermission) {
        switch status {
        case .undetermined: self = .notAsked
        case .denied: self = .denied
        case .granted: self = .granted
        default: self = .cantAsk
        }

    }
    
    @available(iOS 17.0, tvOS 17.0, *)
    init(from status: AVAudioApplication.recordPermission) {
        switch status {
        case .undetermined: self = .notAsked
        case .denied: self = .denied
        case .granted: self = .granted
        default: self = .cantAsk
        }
    }
}
