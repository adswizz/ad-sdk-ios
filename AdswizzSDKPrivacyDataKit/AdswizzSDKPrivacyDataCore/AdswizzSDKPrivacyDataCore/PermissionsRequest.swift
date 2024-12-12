//
//  PermissionsRequest.swift
//  AdswizzSDKPrivacyDataCore
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation

extension PermissionType {
    
    /// Build and link a requester to the `PermissionType`.
    var requester: RequesterProtocol? {
        if !canCheck {
            return nil
        }
        if !isLinkedToLibrary {
            return nil
        }
        
        switch self {
        case .location: return buildLocationRequesterImpl(type: .whenInUse)
#if !os(tvOS)
        case .locationAdvanced: return buildLocationRequesterImpl(type: .always)
#endif
        case .calendar: return buildCalendarRequesterImpl(type: .writeOnly)
        case .calendarAdvanced: return buildCalendarRequesterImpl(type: .full)
        default:
            return buildRequesterImpl()
        }
    }
    
    /// Test if the usage strings are present in the main Bundle's Info.plist. See the `usage` var below.
    private var canCheck: Bool {
        switch self {
        case .idfa:
            if #available(iOS 14, *) {
                return Bundle.main.infoDictionary?[usage] != nil
            } else {
                return true
            }
        default:
            return Bundle.main.infoDictionary?[usage] != nil
        }
    }
    
    /// Test if a class can be loaded from a given library.
    private var isLinkedToLibrary: Bool { libraryImplAnyClass != nil }

    /// Build the `RequesterProtocol` implementation object.
    private func buildRequesterImpl() -> RequesterProtocol? {
        return libraryImplAnyClass?.alloc() as? RequesterProtocol
    }

    /// Build the `LocationRequesterProtocol` implementation objects based on the usage type. See `LocationUsageType` enum for possible values.
    private func buildLocationRequesterImpl(type: LocationUsageType) -> LocationRequesterProtocol? {
        guard let locationClass = libraryImplAnyClass as? LocationRequesterProtocol.Type else {
            return nil
        }
        let locationRequester = locationClass.init(type: type)
        return locationRequester
    }

    /// Build the `CalendarRequesterProtocol` implementation objects based on the access type. See `CalendarAccessType` enum for possible values.
    private func buildCalendarRequesterImpl(type: CalendarAccessType) -> CalendarRequesterProtocol? {
        guard let calendarClass = libraryImplAnyClass as? CalendarRequesterProtocol.Type else {
            return nil
        }
        let calendarRequester = calendarClass.init(type: type)
        return calendarRequester
    }

    /// The associated library class name for the actual implementation.
    private var libraryImplClassName: String {
        switch self {
        case .idfa: return "IDFARequester"
        case .photo: return "PhotoRequester"
        case .speech: return "SpeechRequester"
        case .microphone: return "MicrophoneRequester"
        case .location: return "LocationRequester"
#if !os(tvOS)
        case .locationAdvanced: return "LocationRequester"
#endif
        case .calendar, .calendarAdvanced: return "CalendarRequester"
        case .motionActivity: return "MotionActivityRequester"
        case .contacts: return "ContactsRequester"
        case .camera: return "CameraRequester"
        }
    }
    
    /// The module name.
    private var libraryImplModuleName: String {
        switch self {
        case .idfa: return "AdswizzSDKPrivacyDataIDFA"
        case .photo: return "AdswizzSDKPrivacyDataPhotos"
        case .speech: return "AdswizzSDKPrivacyDataSpeech"
        case .microphone: return "AdswizzSDKPrivacyDataMicrophone"
        case .location: return "AdswizzSDKPrivacyDataLocation"
#if !os(tvOS)
        case .locationAdvanced: return "AdswizzSDKPrivacyDataLocation"
#endif
        case .calendar, .calendarAdvanced: return "AdswizzSDKPrivacyDataCalendar"
        case .motionActivity: return "AdswizzSDKPrivacyDataMotion"
        case .contacts: return "AdswizzSDKPrivacyDataContacts"
        case .camera: return "AdswizzSDKPrivacyDataCamera"
        }
    }
    
    /// Note that in Swift the format needs to be "<namespace>.<className>" where <namespace> is the module name that implements the `RequesterProtocol`.
    private var libraryImplAnyClass: AnyClass? {
        let umbrellaModuleName = "AdswizzSDKPrivacyDataKit"
        return NSClassFromString("\(libraryImplModuleName).\(libraryImplClassName)") ?? NSClassFromString("\(umbrellaModuleName).\(libraryImplClassName)")
    }

    private var usage: String {
        switch self {
        case .location: return "NSLocationWhenInUseUsageDescription"
#if !os(tvOS)
        case .locationAdvanced: return "NSLocationAlwaysUsageDescription"
#endif
        case .photo: return "NSPhotoLibraryUsageDescription"
        case .microphone: return "NSMicrophoneUsageDescription"
        case .speech: return "NSSpeechRecognitionUsageDescription"
        case .calendar:
#if swift(>=5.9)
            if #available(iOS 17.0, *) {
                return "NSCalendarsWriteOnlyAccessUsageDescription"
            } else {
                return "NSCalendarsUsageDescription"
            }
#else
            return "NSCalendarsUsageDescription"
#endif
        case .calendarAdvanced: return "NSCalendarsFullAccessUsageDescription"
        case .contacts: return "NSContactsUsageDescription"
        case .camera: return "NSCameraUsageDescription"
        case .idfa: return "NSUserTrackingUsageDescription"
        case .motionActivity: return "NSMotionUsageDescription"
        }
    }
}
