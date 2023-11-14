//
//  App+Error.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 30.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation

enum AppError: Int {
    case badURL = 100
    case badPlayer = 101
    case badPodcast = 102
}

extension AppError: Error {
}

extension AppError: CustomNSError, LocalizedError {
    static var errorDomain: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    var errorCode: Int {
        return rawValue
    }
    
    var errorDescription: String? {
        switch self {
        case .badURL: return "Bad url!"
        case .badPlayer: return "Bad player state!"
        case .badPodcast: return "Bad podcast!"
        }
    }
    
    func with(_ message: String) -> Error {
        return NSError(domain: AppError.errorDomain,
                       code: rawValue,
                       userInfo: [NSLocalizedDescriptionKey: message])
    }
}

extension NSError {
    var appError: AppError? {
        return AppError(rawValue: code)
    }
}
