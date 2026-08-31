//
//  AppLogger.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 16.06.2026.
//

import AdswizzSDK
import AdswizzSDKCore

public final class AppLogger: Sendable {
    public init() {}

    public func log(_ line: String) {
        print("App log: \(line)")
    }
}

extension AppLogger: AdLoggerDestination {
    public func log(_ level: AdLogger.Level, functionName: String, fileName: String, lineNumber: Int, line: String) {
        print("AdswizzSDK log: \(line)")
    }
}
