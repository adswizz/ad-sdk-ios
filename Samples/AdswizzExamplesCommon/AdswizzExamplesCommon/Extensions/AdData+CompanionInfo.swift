//
//  AdData+CompanionInfo.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK

extension AdData {
    public func printCompanionInformation() {
        if hasCompanion {
            print("[Companion] has information for AdId: \(id ?? "unknown")")
        } else {
            print("[Companion] <<none>>")
        }
    }
}
