//
//  AdManager+Extensions.swift
//  BasicPodcastExample
//
//  Created by Adrian Manolache on 15.02.2022.
//

import Foundation
import AdswizzSDK

extension AdManager {
    /// The current number of playbable ads
    var adCount: Int {
        return ads.count
    }

    /// The total number of seconds for all playable ads
    var totalAdsDuration: TimeInterval {
        return ads.compactMap { $0.duration }.reduce(0, +)
    }
}
