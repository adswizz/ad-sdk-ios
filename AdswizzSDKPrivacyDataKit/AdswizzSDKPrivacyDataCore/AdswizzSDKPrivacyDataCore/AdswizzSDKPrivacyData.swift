//
//  AdswizzSDKPrivacyData.swift
//  AdswizzSDKPrivacyDataCore
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import Speech

/// Supported types of permission values.
@objc public enum PermissionValue: Int {
    /// Permission is granted.
    case granted
    /// Permission is denied.
    case denied
    /// Permission was not asked yet
    case notAsked
    /// Permission can't be asked, either because the usage string is missing in app's Info.plist or the it was compiled without that permission.
    case cantAsk
    
    /// Convenience helper to obtain the String representation of a `PermissionValue`.
    public var stringRepresentation: String {
        switch self {
        case .granted: return "granted"
        case .denied: return "denied"
        case .notAsked: return "notAsked"
        case .cantAsk: return "cantAsk"
        }
    }
}

/// Supported types of permissions that might be requested.
@objc public enum PermissionType: Int {
    /// Location - when in use.
    case location
    /// Location - when always.
    case locationAdvanced
    /// Photos.
    case photo
    /// Microphone.
    case microphone
    /// Speech.
    case speech
    /// Calendar - write only.
    case calendar
    /// Calendar - full access (iOS 17+).
    case calendarAdvanced
    /// Contacts.
    case contacts
    /// Camera.
    case camera
    /// Tracking as defined per the ATT framework.
    case idfa
    /// Motion.
    case motionActivity
}

extension PermissionType {
    /// All types bundled in a collection.
    public static let all: [PermissionType] = [.location, .locationAdvanced, .photo, .microphone, .speech, .camera, .calendar, .calendarAdvanced, .contacts, .idfa, .motionActivity]
}

/// AdswizzSDKPermissions - Access and request permissions
@objc public protocol AdswizzSDKPermissions {
    /// Returns the authorization status as defined in the `PermissionValue`.
    func authorizationStatus(for permission: PermissionType) -> PermissionValue
    
    /// Attempt to request permission `type` with a `completion` block.
    func request(permission type: PermissionType, completion: @escaping RequestCompletion)
}

/// AdswizzSDKFactory - create wrappers for sensitive objects that require permissions
@objc public protocol AdswizzSDKFactory {
    func buildActivityManager() -> MotionActivityManager?
    func buildSpeechRecognizer(locale: Locale) -> SpeechRecognizer?
}

/// Main frm class
@objc public class AdswizzSDKPrivacyData: NSObject {
    /// The shared instance.
    @objc public static let shared = AdswizzSDKPrivacyData()
    let requesters: [PermissionType: RequesterProtocol]
    
    override init() {
        let permissions: [(PermissionType, RequesterProtocol)] = PermissionType.all.compactMap {
            if let requester = $0.requester {
                return ($0, requester)
            } else {
                return nil
            }
        }
        requesters = Dictionary(uniqueKeysWithValues: permissions)
    }
    
}

//MARK: - AdswizzSDKPermissions
extension AdswizzSDKPrivacyData: AdswizzSDKPermissions {
    public func request(permission type: PermissionType, completion: @escaping RequestCompletion) {
        guard let requester = requesters[type] else {
            completion(RequestResult(success: .cantAsk))
            return
        }
        
        if requester.authorizationStatus != .notAsked {
            completion(RequestResult(success: requester.authorizationStatus))
            return
        }
        
        requester.request { output in
            DispatchQueue.main.async {
                completion(output)
            }
        }
    }
    
    public func authorizationStatus(for permission: PermissionType) -> PermissionValue {
        return requesters[permission]?.authorizationStatus ?? .cantAsk
    }
}

//MARK: - AdswizzSDKFactory
extension AdswizzSDKPrivacyData: AdswizzSDKFactory {
    public func buildActivityManager() -> MotionActivityManager? {
        return NSClassFromString("AdswizzSDKPrivacyDataMotion.MotionActivityManagerImpl")?.alloc() as? MotionActivityManager
    }
    
    public func buildSpeechRecognizer(locale: Locale) -> SpeechRecognizer? {
        guard let speechRecognizerClass = NSClassFromString("AdswizzSDKPrivacyDataSpeech.SpeechRecognizerImpl") as? SpeechRecognizer.Type else {
                return nil
            }
        let speechRecognizerImpl = speechRecognizerClass.init(locale: locale)
        return speechRecognizerImpl
    }
}

//MARK: - Motion Activity
/// Motion activity confidence wrapper.
@objc public enum MotionActivityConfidence: Int {
    case low = 0
    case medium
    case high
}

/// Motion activity wrapper.
@objc public protocol MotionActivity: AnyObject {
    var activityConfidence: MotionActivityConfidence { get }
    var startDate: Date { get }
    var unknown: Bool { get }
    var stationary: Bool { get }
    var walking: Bool { get }
    var running: Bool { get }
    var automotive: Bool { get }
    var cycling: Bool { get }
}

/// Motion activity manager wrapper.
@objc public protocol MotionActivityManager: AnyObject {
    func startActivity(to queue: OperationQueue, withHandler handler: @escaping (MotionActivity?) -> ())
    func stopActivity()
}

//MARK: - Speech recognizer
/// SFSpeechRecognizer wrapper.
@objc public protocol SpeechRecognizer: AnyObject {
    init?(locale: Locale)
    func recognitionTask(with request: SFSpeechRecognitionRequest, resultHandler: @escaping (SFSpeechRecognitionResult?, Error?) -> Void) -> SFSpeechRecognitionTask
}

//MARK: - Location
/// Location usage type.
@objc public enum LocationUsageType: Int {
    case whenInUse
    case always
}

/// `LocationRequesterProtocol` based on `RequesterProtocol`.
@objc public protocol LocationRequesterProtocol: RequesterProtocol {
    init(type: LocationUsageType)
}

//MARK: - Calendar
/// Calendar access type.
@objc public enum CalendarAccessType: Int {
    case writeOnly
    case full
}

/// `CalendarRequesterProtocol` based on `RequesterProtocol`.
@objc public protocol CalendarRequesterProtocol: RequesterProtocol {
    init(type: CalendarAccessType)
}
