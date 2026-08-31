//
//  Bundle+Version.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//  Copyright © 2026 Adswizz. All rights reserved.
//

import Foundation

extension Bundle {
    public var version: String {
        let buildNumber: String = infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        let shortVersion: String = infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        return "\(shortVersion) (\(buildNumber))"
    }
}
