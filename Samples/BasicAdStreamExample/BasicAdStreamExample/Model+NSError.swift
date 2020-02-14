//
//  Model+NSError.swift
//  BasicAdStreamExample
//
//  Created by Teodor Cristea on 12/02/2020.
//  Copyright © 2020 Inc, AdsWizz. All rights reserved.
//

import Foundation

enum ModelError: Int {
    case badStreamURL = 100
}

extension ModelError: Error {
}

extension ModelError: CustomNSError, LocalizedError {
    static var errorDomain: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    var errorCode: Int {
        return rawValue
    }
    
    var errorDescription: String? {
        switch self {
        case .badStreamURL: return "Bad url used to start playing an ad stream!"
        }
    }
}

extension NSError {
    var modelError: ModelError? {
        return ModelError(rawValue: code)
    }
}
