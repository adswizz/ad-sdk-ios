//
//  NSError+PrivacyDataErrors.swift
//  AdswizzSDKPrivacyDataCore
//
//  Created by Teodor Cristea on 29.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation

enum AdswizzPrivacyDataError: Int {
    case unknownResult = 9100
}

extension AdswizzPrivacyDataError: Error {}

extension AdswizzPrivacyDataError: CustomNSError, LocalizedError {
    static var errorDomain: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    var errorCode: Int {
        return rawValue
    }
    
    var errorDescription: String? {
        switch self {
        case .unknownResult: return "Unknown request result!"
        }
    }
    
    func error(_ message: String? = nil) -> Error {
        let description = message ?? errorDescription
        return NSError(domain: AdswizzPrivacyDataError.errorDomain,
                       code: rawValue,
                       userInfo: [NSLocalizedDescriptionKey: description ?? "Unknown error description!"])
    }
}

extension NSError {
    var privacyDataError: AdswizzPrivacyDataError? {
        return AdswizzPrivacyDataError(rawValue: code)
    }
}
