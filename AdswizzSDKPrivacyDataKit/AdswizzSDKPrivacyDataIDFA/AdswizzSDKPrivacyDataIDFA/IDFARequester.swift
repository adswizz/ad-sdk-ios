//
//  IDFARequester.swift
//  AdswizzSDKPrivacyDataIDFA
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import AdSupport
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

/// Requester implementation for the IDFA (tracking) system permission as defined under Apple's ATT framework.
///
/// - note: The `AdswizzSDKPrivacyDataCore` module links the `IDFARequester` automatically at runtime if the `AdswizzSDKPrivacyDataIDFA` module is installed as library.
///
/// - see: Apple's document on user privacy for details of available authorisations
/// https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy
///
@objc class IDFARequester: NSObject, RequesterProtocol {
    override init() {}
    
    var authorizationStatus: PermissionValue {
        return PermissionValue(from: IDFAPemissionStatus.current)
    }
    
    func request(completion: @escaping RequestCompletion) {
        #if canImport(AppTrackingTransparency)
            if #available(iOS 14, tvOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    completion(RequestResult(success: PermissionValue(from: IDFAPemissionStatus(from: status))))
                }
            } else {
                completion(RequestResult(success: .granted))
            }
        #else
            completion(.success(.granted))
        #endif
    }
}

enum IDFAPemissionStatus: String {
    case authorized
    case denied
    case notDetermined
    case restricted
}

#if canImport(AppTrackingTransparency)
extension IDFAPemissionStatus {
    @available(iOS 14, tvOS 14, *)
    init(from status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .restricted: self = .restricted
        case .authorized: self = .authorized
        case .notDetermined: self = .notDetermined
        case .denied: self = .denied
        @unknown default:
            self = .notDetermined
        }
    }
}

extension IDFAPemissionStatus {
    static var current: IDFAPemissionStatus {
        if #available(iOS 14, tvOS 14, *) {
            return IDFAPemissionStatus(from: ATTrackingManager.trackingAuthorizationStatus)
        } else {
            return ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? .authorized : .denied
        }
    }
}
#else
extension IDFAPemissionStatus {
    static var current: IDFAPemissionStatus {
        return ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? .authorized : .denied
    }
}
#endif

extension PermissionValue {
    init(from status: IDFAPemissionStatus) {
        switch status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
        case .authorized: self = .granted
        }
    }
}

