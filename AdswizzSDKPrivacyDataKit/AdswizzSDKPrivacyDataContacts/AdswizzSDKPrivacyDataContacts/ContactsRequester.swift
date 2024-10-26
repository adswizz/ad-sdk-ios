//
//  ContactsRequester.swift
//  AdswizzSDKPrivacyDataContacts
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import Contacts

/// Requester implementation for the contacts system permission.
///
/// - note: The `AdswizzSDKPrivacyDataCore` module links the `ContactsRequester` automatically at runtime if the `AdswizzSDKPrivacyDataContacts` module is installed as library.
///
/// - see: Apple's document on user privacy for details of available authorisations
/// https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy
///
@objc class ContactsRequester: NSObject, RequesterProtocol {
    var authorizationStatus: PermissionValue {
        return PermissionValue(from: CNContactStore.authorizationStatus(for: .contacts))
    }
    
    func request(completion: @escaping RequestCompletion) {
        CNContactStore().requestAccess(for: .contacts) { granted, error in
            if let error = error {
                completion(RequestResult(success: .cantAsk, failure: error))
            } else {
                completion(RequestResult(success: granted ? .granted : .denied))
            }
        }
    }
}

extension PermissionValue {
    init(from status: CNAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
        case .authorized: self = .granted
        default: self = .cantAsk
        }
    }
}
