//
//  LocationRequester.swift
//  AdswizzSDKPrivacyDataLocation
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import UIKit
import CoreLocation

/// Requester implementation for the location system permission.
///
/// - note: The `AdswizzSDKPrivacyDataCore` module links the `LocationRequester` automatically at runtime if the `AdswizzSDKPrivacyDataLocation` module is installed as library.
///
/// - see: Apple's document on user privacy for details of available authorisations
/// https://developer.apple.com/documentation/uikit/core_app/protecting_the_user_s_privacy
///
@objc class LocationRequester: NSObject, LocationRequesterProtocol {
    let locationUsage: LocationUsageType
    private let locationManager: CLLocationManager
    private var completion: RequestCompletion?
    private var isRequesting = false
    private var lock = NSRecursiveLock()
    private var currentStatus: CLAuthorizationStatus = .notDetermined
    
    required init(type: LocationUsageType) {
        locationUsage = type
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }
    
    var authorizationStatus: PermissionValue {
        defer { lock.unlock() }
        lock.lock()
        switch locationUsage {
        case .always: return PermissionValue(from: LocationAlwaysStatus(for: currentStatus))
        case .whenInUse: return PermissionValue(from: LocationWhenInUseStatus(for: currentStatus))
        @unknown default:
            return .cantAsk
        }
    }
    
    func request(completion: @escaping RequestCompletion) {
        DispatchQueue.main.async { [weak self] in
            self?.internalRequest(completion: completion)
        }
    }
}

extension LocationRequester: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //Fix for AASDK-1981.
        //update the current status if needed
        lock.lock()
#if canImport(AppTrackingTransparency)
    if #available(iOS 14.0, *) {
        currentStatus = manager.authorizationStatus
    } else {
        currentStatus = .denied
    }
#else
        currentStatus = CLLocationManager.authorizationStatus()
#endif
        //end update
        lock.unlock()

        if !isRequesting {
            return
        }
        defer { cleanUp() }

        switch locationUsage {
        case .whenInUse: completion?(RequestResult(success: PermissionValue(from: LocationWhenInUseStatus(for: currentStatus))))
        case .always: completion?(RequestResult(success: PermissionValue(from: LocationAlwaysStatus(for: currentStatus))))
        @unknown default:
            completion?(RequestResult(success: .cantAsk))
        }
    }
}

private extension LocationRequester {
    func internalRequest(completion: @escaping RequestCompletion) {
        self.completion = completion
        isRequesting = true
        
        switch locationUsage {
        case .whenInUse:
            if UIApplication.shared.applicationState == .active {
                if currentStatus == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
                } else {
                    cleanUp()
                    completion(RequestResult(success: PermissionValue(from: LocationWhenInUseStatus(for: currentStatus))))
                }
            } else {
                cleanUp()
                completion(RequestResult(success: .cantAsk))
            }
        case .always:
            if currentStatus == .notDetermined || currentStatus == .authorizedWhenInUse {
                locationManager.requestAlwaysAuthorization()
            } else {
                cleanUp()
                completion(RequestResult(success: PermissionValue(from: LocationAlwaysStatus(for: currentStatus))))
            }
        @unknown default:
            completion(RequestResult(success: .cantAsk))
        }
    }
    
    private func cleanUp() {
        isRequesting = false
        completion = nil
    }
}

class LocationWhenInUseStatus {
    let status: CLAuthorizationStatus
    init(for status: CLAuthorizationStatus) {
        self.status = status
    }
}

extension PermissionValue {
    init(from status: LocationWhenInUseStatus) {
        switch status.status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
        case .authorizedWhenInUse: self = .granted
        case .authorizedAlways: self = .granted
        default: self = .cantAsk
        }

    }
}

class LocationAlwaysStatus: LocationWhenInUseStatus {
}

extension PermissionValue {
    init(from status: LocationAlwaysStatus) {
        switch status.status {
        case .notDetermined: self = .notAsked
        case .denied, .restricted: self = .denied
        case .authorizedWhenInUse: self = .denied
        case .authorizedAlways: self = .granted
        default: self = .cantAsk
        }

    }
}
