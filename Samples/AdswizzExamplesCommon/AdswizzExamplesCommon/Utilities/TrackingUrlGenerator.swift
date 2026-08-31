//
//  TrackingUrlGenerator.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 16.06.2026.
//

import Foundation

/// Helpers to generate custom tracking URLs to be fired by AdswizzSDK along with VAST tracking URLs.
public enum TrackingUrlGenerator {
    public static let customTrackingUrl =
        "https://www.adswizz.com/tracking/[TYPE]/[INDEX]/macros/state=[PLAYERSTATE]&adCount=[ADTYPE]"

    public static func generateTrackingUrls(
        for type: String,
        count: Int = 1,
        template: String = customTrackingUrl
    ) -> [URL] {
        (0..<count).compactMap {
            URL(string: template
                .replacingOccurrences(of: "[TYPE]", with: type)
                .replacingOccurrences(of: "[INDEX]", with: "\($0 + 1)"))
        }
    }
}
