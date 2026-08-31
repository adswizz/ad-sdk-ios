//
//  AdManager+Convenience.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK

extension AdManager {
    /// The current number of playable ads
    public var adCount: Int {
        return ads.count
    }

    /// The total number of seconds for all playable ads
    public var totalAdsDuration: TimeInterval {
        return ads.compactMap { $0.duration }.reduce(0, +)
    }
}
