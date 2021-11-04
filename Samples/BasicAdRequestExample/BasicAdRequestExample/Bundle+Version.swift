//
//  Bundle+Version.swift
//  BasicAdRequestExample
//
//  Created by Ciprian Caba on 10/19/21.
//  Copyright © 2021 Inc, AdsWizz. All rights reserved.
//

import Foundation

extension Bundle {
    var version: String {
        let buildNumber: String = infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        let shortVersion: String = infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        return "\(shortVersion) (\(buildNumber))"
    }
}
