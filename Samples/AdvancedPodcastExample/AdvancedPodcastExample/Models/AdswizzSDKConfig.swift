//
//  AdswizzSDKConfig.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 30.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation
import AdswizzSDK

struct AdswizzSDKInit {
    class BundleDummy {}
    let installationId = Bundle(for: AdswizzSDKInit.BundleDummy.self).installationId ?? ""
    let playerId = Bundle(for: AdswizzSDKInit.BundleDummy.self).playerId ?? ""
    let appStoreId = Bundle(for: AdswizzSDKInit.BundleDummy.self).appStoreId ?? ""
}

extension Bundle {
    var version: String {
        let buildNumber: String = infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        let shortVersion: String = infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        return "\(shortVersion) (\(buildNumber))"
    }
    
    var installationId: String? {
        return object(forInfoDictionaryKey: AdswizzSettingsKeys.InstallationId) as? String
    }
    
    var playerId: String? {
        return object(forInfoDictionaryKey: AdswizzSettingsKeys.PlayerId) as? String
    }
    
    var appStoreId: String? {
        return object(forInfoDictionaryKey: AdswizzSettingsKeys.AppStoreId) as? String
    }
}
