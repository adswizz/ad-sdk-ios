//
//  CalendarRequester.swift
//  AdswizzSDKPrivacyDataCalendar
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import EventKit
import UIKit

/// Requester implementation for the calendar system permission.
///
/// - note: The `AdswizzSDKPrivacyDataCore` module links the `CalendarRequester` automatically at runtime if the `AdswizzSDKPrivacyDataCalendar` module is installed as library.
///
/// - see: Apple's document on user privacy for details of available authorisations
/// https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy
///
@objc class CalendarRequester: NSObject, CalendarRequesterProtocol, @unchecked Sendable {
    let calendarAccess: CalendarAccessType
    var authorizationStatus: PermissionValue {
        switch calendarAccess {
        case .writeOnly: return PermissionValue(from: CalendarWriteOnlyStatus(for: currentStatus))
        case .full: return PermissionValue(from: CalendarFullStatus(for: currentStatus))
        @unknown default:
            return .cantAsk
        }
    }
    
    var currentStatus: EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }

    required init(type: CalendarAccessType) {
        calendarAccess = type
    }
    
    func request(completion: @escaping RequestCompletion) {
        DispatchQueue.main.async { [weak self] in
            self?.internalRequest(completion: completion)
        }
    }
}

private extension CalendarRequester {
    func internalRequest(completion: @escaping RequestCompletion) {
        
        let completed: @Sendable (Bool, Error?) -> () = { [weak self] _, error in
            if let error = error {
                completion(RequestResult(success: .cantAsk, failure: error))
            } else {
                self?.internalDidRequest(completion)
            }
        }
        
#if swift(>=5.9)
        if #available(iOS 17.0, *) {
            switch calendarAccess {
            case .writeOnly:
                if currentStatus == .notDetermined {
                    EKEventStore().requestWriteOnlyAccessToEvents(completion: completed)
                } else {
                    internalDidRequest(completion)
                }
            case .full:
                if currentStatus == .notDetermined || currentStatus == .writeOnly {
                    EKEventStore().requestFullAccessToEvents(completion: completed)
                } else {
                    internalDidRequest(completion)
                }
            @unknown default:
                internalDidRequest(completion)
            }
        } else {
            EKEventStore().requestAccess(to: .event, completion: completed)
        }
#else
        EKEventStore().requestAccess(to: .event, completion: completed)
#endif
    }
        
    func internalDidRequest(_ completion: @escaping RequestCompletion) {
        switch calendarAccess {
        case .writeOnly: completion(RequestResult(success: PermissionValue(from: CalendarWriteOnlyStatus(for: currentStatus))))
        case .full: completion(RequestResult(success: PermissionValue(from: CalendarFullStatus(for: currentStatus))))
        @unknown default:
            completion(RequestResult(success: .cantAsk))
        }
    }
}

class CalendarWriteOnlyStatus {
    let status: EKAuthorizationStatus
    init(for status: EKAuthorizationStatus) {
        self.status = status
    }
}

extension PermissionValue {
    init(from status: CalendarWriteOnlyStatus) {
        switch status.status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
#if swift(>=5.9)
        //iOS 17+ with XCode >= 15.0
        case .writeOnly, .fullAccess: self = .granted
#else
        //Deprecated in iOS 17 with XCode <= 15.0
        case .authorized: self = .granted
#endif
        default: self = .cantAsk
        }
    }
}

class CalendarFullStatus: CalendarWriteOnlyStatus {}

extension PermissionValue {
    init(from status: CalendarFullStatus) {
        switch status.status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
#if swift(>=5.9)
        //iOS 17+ with XCode >= 15.0
        case .writeOnly: self = .denied
        case .fullAccess: self = .granted
#else
        //Deprecated in iOS 17 with XCode <= 15.0
        case .authorized: self = .granted
#endif
        default: self = .cantAsk
        }
    }
}
